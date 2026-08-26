"""Lab E2E pipeline: Lambda -> Glue || ECS -> Athena -> SNS (U4)."""
from __future__ import annotations

import json
import os
import time
from datetime import datetime, timedelta

import boto3
from airflow import DAG
from airflow.models import Variable
from airflow.operators.empty import EmptyOperator
from airflow.operators.python import BranchPythonOperator, PythonOperator
from airflow.providers.amazon.aws.operators.athena import AthenaOperator
from airflow.providers.amazon.aws.operators.glue import GlueJobOperator
from airflow.providers.amazon.aws.operators.lambda_function import LambdaInvokeFunctionOperator
from airflow.utils.trigger_rule import TriggerRule

DEFAULT_ARGS = {
    "owner": "lab",
    "retries": 1,
    "retry_delay": timedelta(seconds=60),
}


def _var(key: str, default: str = "") -> str:
    try:
        return Variable.get(key, default_var=default)
    except Exception:
        return default


def _aws_region() -> str:
    return (
        (_var("lab_aws_region") or "").strip()
        or os.environ.get("AWS_DEFAULT_REGION")
        or os.environ.get("AWS_REGION")
        or "us-east-1"
    )


def _boto3(service: str):
    return boto3.client(service, region_name=_aws_region())


def _require(key: str) -> str:
    value = (_var(key) or "").strip()
    if not value:
        raise ValueError(
            f"Airflow Variable '{key}' is required — run scripts/set-airflow-variables and paste via SSM"
        )
    return value


def _schedule():
    raw = (_var("lab_e2e_schedule") or "").strip()
    return raw or None


def on_failure_callback(context):
    topic = _var("lab_sns_topic_arn")
    if not topic:
        return
    ti = context.get("task_instance")
    exc = context.get("exception")
    dag = context.get("dag")
    payload = {
        "dag_id": dag.dag_id if dag else None,
        "run_id": context.get("run_id"),
        "status": "failed",
        "failed_task_id": ti.task_id if ti else None,
        "exception": str(exc)[:500] if exc else None,
    }
    ui_base = (_var("lab_airflow_ui_base") or "").rstrip("/")
    if ui_base and payload["dag_id"]:
        payload["airflow_ui_url"] = (
            f"{ui_base}/dags/{payload['dag_id']}/grid?dag_run_id={payload['run_id']}"
        )
    _boto3("sns").publish(
        TopicArn=topic,
        Subject=f"lab_pipeline_e2e FAILED {payload.get('failed_task_id')}",
        Message=json.dumps(payload, default=str),
    )


def run_ecs_fargate(**_context):
    cluster = _require("lab_ecs_cluster")
    task_def = _require("lab_ecs_task_definition")
    subnets = [s.strip() for s in _require("lab_ecs_subnets").split(",") if s.strip()]
    sgs = [s.strip() for s in _require("lab_ecs_security_groups").split(",") if s.strip()]
    ecs = _boto3("ecs")
    resp = ecs.run_task(
        cluster=cluster,
        taskDefinition=task_def,
        launchType="FARGATE",
        count=1,
        networkConfiguration={
            "awsvpcConfiguration": {
                "subnets": subnets,
                "securityGroups": sgs,
                "assignPublicIp": "DISABLED",
            }
        },
    )
    failures = resp.get("failures") or []
    if failures:
        raise RuntimeError(f"ECS RunTask failures: {failures}")
    tasks = resp.get("tasks") or []
    if not tasks:
        raise RuntimeError("ECS RunTask returned no tasks")
    task_arn = tasks[0]["taskArn"]
    deadline = time.time() + 30 * 60
    while time.time() < deadline:
        desc = ecs.describe_tasks(cluster=cluster, tasks=[task_arn])
        task = (desc.get("tasks") or [None])[0]
        if not task:
            raise RuntimeError(f"ECS task disappeared: {task_arn}")
        last = task.get("lastStatus")
        if last == "STOPPED":
            exit_code = None
            for c in task.get("containers") or []:
                if c.get("exitCode") not in (None, 0):
                    raise RuntimeError(f"ECS container failed: {c}")
                exit_code = c.get("exitCode", exit_code)
            if exit_code not in (0, None):
                raise RuntimeError(f"ECS task exitCode={exit_code}")
            return task_arn
        time.sleep(15)
    raise TimeoutError(f"ECS task timed out: {task_arn}")


def branch_select(**_context):
    enabled = (_var("lab_e2e_enable_select", "false") or "false").lower() == "true"
    return "sensor_seed_data" if enabled else "skip_select"


def sensor_seed_data(**_context):
    database = _require("lab_glue_database")
    tables = _boto3("glue").get_tables(DatabaseName=database).get("TableList") or []
    if not tables:
        raise RuntimeError(
            f"No tables in Glue database '{database}'. "
            "Run seed-sample.sh + crawler, or set lab_e2e_enable_select=false."
        )
    return tables[0]["Name"]


def publish_success(**context):
    topic = _require("lab_sns_topic_arn")
    enable_select = (_var("lab_e2e_enable_select", "false") or "false").lower() == "true"
    ti = context["ti"]
    query_id = ti.xcom_pull(task_ids="athena_show_tables")
    select_qid = ti.xcom_pull(task_ids="athena_select") if enable_select else None
    payload = {
        "dag_id": context["dag"].dag_id,
        "run_id": context["run_id"],
        "status": "success",
        "execution_date": str(context.get("logical_date") or context.get("execution_date")),
        "select_executed": bool(enable_select and select_qid is not None),
        "select_skipped": not enable_select,
        "lambda_function_name": _var("lab_lambda_function_name"),
        "glue_job_name": _var("lab_glue_job_name"),
        "ecs_cluster": _var("lab_ecs_cluster"),
        "ecs_task_definition": _var("lab_ecs_task_definition"),
        "sns_topic_arn": topic,
        "query_execution_id": select_qid or query_id,
    }
    _boto3("sns").publish(
        TopicArn=topic,
        Subject="lab_pipeline_e2e SUCCESS",
        Message=json.dumps(payload, default=str),
    )


with DAG(
    dag_id="lab_pipeline_e2e",
    start_date=datetime(2024, 1, 1),
    schedule=_schedule(),
    catchup=False,
    max_active_runs=1,
    default_args={**DEFAULT_ARGS, "on_failure_callback": on_failure_callback},
    tags=["u4", "e2e", "lab"],
    doc_md="E2E lab: Lambda → Glue ∥ ECS → Athena SHOW → optional SELECT → SNS.",
) as dag:
    invoke_lambda = LambdaInvokeFunctionOperator(
        task_id="task_invoke_lambda",
        function_name="{{ var.value.lab_lambda_function_name }}",
        region_name=_aws_region(),
        execution_timeout=timedelta(minutes=5),
    )

    start_glue = GlueJobOperator(
        task_id="task_start_glue_job",
        job_name="{{ var.value.lab_glue_job_name }}",
        region_name=_aws_region(),
        wait_for_completion=True,
        execution_timeout=timedelta(minutes=45),
    )

    run_ecs = PythonOperator(
        task_id="task_run_ecs_fargate",
        python_callable=run_ecs_fargate,
        execution_timeout=timedelta(minutes=30),
    )

    athena_show = AthenaOperator(
        task_id="athena_show_tables",
        query="SHOW TABLES IN `{{ var.value.lab_glue_database }}`",
        database="{{ var.value.lab_glue_database }}",
        output_location="{{ var.value.lab_athena_output_s3 }}",
        workgroup="{{ var.value.lab_athena_workgroup }}",
        region_name=_aws_region(),
        execution_timeout=timedelta(minutes=15),
    )

    branch = BranchPythonOperator(
        task_id="branch_select",
        python_callable=branch_select,
    )

    sensor = PythonOperator(
        task_id="sensor_seed_data",
        python_callable=sensor_seed_data,
        execution_timeout=timedelta(minutes=5),
    )

    # Dynamic table name from sensor XCom
    athena_select = AthenaOperator(
        task_id="athena_select",
        query=(
            "SELECT * FROM `{{ var.value.lab_glue_database }}`.`{{ ti.xcom_pull(task_ids='sensor_seed_data') }}` "
            "LIMIT 10"
        ),
        database="{{ var.value.lab_glue_database }}",
        output_location="{{ var.value.lab_athena_output_s3 }}",
        workgroup="{{ var.value.lab_athena_workgroup }}",
        region_name=_aws_region(),
        execution_timeout=timedelta(minutes=15),
    )

    skip_select = EmptyOperator(task_id="skip_select")

    publish = PythonOperator(
        task_id="task_publish_sns",
        python_callable=publish_success,
        trigger_rule=TriggerRule.NONE_FAILED_MIN_ONE_SUCCESS,
        execution_timeout=timedelta(minutes=2),
    )

    invoke_lambda >> [start_glue, run_ecs] >> athena_show >> branch
    branch >> sensor >> athena_select >> publish
    branch >> skip_select >> publish
