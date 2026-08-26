# Shared Infrastructure

**Scope**: Recursos provisionados em **U1 Foundation**, **U1-orchestrator-ec2 (delta)**, **U2**, **U3**, **U4**, consumidos pelo lab E2E.

> **Amendment (2026-08-24)**: Orquestrador default = **EC2 Airflow** (`orchestrator_mode=ec2`). MWAA opcional.  
> **Amendment (2026-08-26)**: U4 adiciona **SNS NotifyTopic** + `airflow_variables_map`; IAM SNS no **root**.

## Shared Resources

| Resource | Owner unit | Consumers |
|---|---|---|
| VPC + subnets + NAT + S3 Gateway Endpoint | U1 | U3 ECS; EC2 Airflow (public); MWAA (optional) |
| MWAA Security Group | U1 | MWAA only (mode=mwaa) |
| Artifact S3 bucket | U1 | EC2 bootstrap/sync; MWAA (optional); U3 Glue script; U4 sync + requirements |
| **EC2 Airflow host** | **U1-orchestrator-ec2** | **U4 DAG runtime (default)** |
| **EC2 orchestrator IAM role** | **U1-orchestrator-ec2** | **U2/U3/U4 policies (default)** |
| MWAA Environment | U1 (mode=mwaa) | U4 DAG (optional) |
| MWAA Execution Role | U1 (mode=mwaa) | U2/U3/U4 (optional) |
| Default tags / name prefix / region var | Root | All units |
| `policies/terraform-apply-policy.json` | U1 | Operator whole-platform apply |
| Data lake S3 bucket | U2 | U3 writers; U4 DAG / Athena |
| Athena results S3 bucket | U2 | U4 |
| Glue Database | U2 | U3, U4 |
| Glue Crawlers | U2 | U4 |
| Lake Formation | U2 | U3/U4; orchestrator role |
| Athena workgroup | U2 | U4 |
| Lambda / Glue / ECS | U3 | U4 DAG invoke |
| **SNS pipeline status topic** | **U4** | **DAG notify; optional email** |

## Non-Shared (unit-local)
| Resource | Unit |
|---|---|
| DAG `lab_pipeline_e2e.py` + `requirements.txt` | U4 (code in repo; runtime on EC2) |
| Compose stack on EC2 | U1-orchestrator-ec2 (runtime; bootstrap may install requirements) |
| `set-airflow-variables` scripts | U4 operator tooling |

## Contract for Downstream / Operator

Downstream modules **must not** recreate VPC/artifact/lake/executors/SNS. Consume outputs:

```text
# Orchestrator (always)
orchestrator_mode
orchestrator_role_arn    # EC2 role (default) or MWAA role (mode=mwaa)

# From U1 / EC2 mode (default)
airflow_ec2_instance_id
airflow_ec2_public_ip
airflow_ui_url
airflow_ec2_role_arn     # same principal as orchestrator_role_arn in ec2 mode

# From U1 (shared)
vpc_id
public_subnet_id
private_subnet_ids
artifact_bucket_name / arn
aws_region
name_prefix

# From U1 MWAA mode (optional)
mwaa_environment_name / arn
mwaa_execution_role_arn

# From U2
data_lake_bucket_name / arn
athena_results_bucket_name / arn
glue_database_name
raw_crawler_name
processed_crawler_name
athena_workgroup_name

# From U3
lambda_function_arn / name
glue_job_name
ecs_cluster_arn
ecs_task_definition_arn
ecs_security_group_id

# From U4
sns_topic_arn
sns_topic_name
airflow_variables_map    # object for set-airflow-variables helper
```

### Airflow Variables contract
Operador popula Variables a partir de `airflow_variables_map` (script emite `airflow variables set` para SSM). Keys: `lab_lambda_function_name`, `lab_glue_job_name`, `lab_ecs_*`, `lab_athena_*`, `lab_glue_database`, `lab_sns_topic_arn`, `lab_e2e_enable_select`, `lab_e2e_schedule`, `lab_airflow_ui_base`.

## Change Control
- Default orchestrator is EC2; lake/compute/SNS IAM attaches to `orchestrator_role_arn` (SNS via **root** policies in U4).
- Switching to MWAA requires `orchestrator_mode=mwaa` + account subscription.
- LF Data Lake administrator remains manual account prerequisite.
- U1 EC2 status-check alarm remains **without** SNS action (pipeline SNS is DAG-driven only).
