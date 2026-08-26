# U4-orchestration-notify — Deployment Architecture

## Topology (delta)

```text
Operator workstation
  |-- terraform apply (root)
  |-- sync-dags + requirements path
  |-- set-airflow-variables (print) -> SSM paste on EC2
  |-- browser UI :8080 / trigger DAG
  v
EC2 Airflow (U1) ----invoke----> Lambda / Glue / ECS (U3)
       |                              |
       |---- Athena queries --------> Workgroup + results S3 (U2)
       |
       +---- sns:Publish -----------> SNS topic (U4)
                                        |
                                        +-- optional email subscription
```

## Apply Sequence

```text
1. terraform fmt / validate / plan / apply
   - creates module.sns (topic, optional email sub, topic policy)
   - attaches root IAM: sns:Publish (+ glue:GetTable if missing)
   - refreshes airflow_ec2 S3 objects (bootstrap with pip install)
2. Confirm email subscription in inbox (if email var set)
3. scripts/sync-dags.* (DAG + ensure requirements on ArtifactStore per doc)
4. Wait DagSyncAgent (~5 min) or force sync on host
5. EC2 bootstrap/restart path so pip requirements applied (document exact restart)
6. scripts/set-airflow-variables.* -> copy commands via SSM
7. Trigger lab_pipeline_e2e in UI
8. Verify SNS message (+ Athena results); stop EC2 when done
```

## Module Wiring (root)

```text
module.sns
  inputs: name_prefix, tags, sns_notification_email, publisher_role_arn = local.orchestrator_role_arn
  outputs: topic_arn, topic_name

root IAM (new):
  aws_iam_role_policy "orchestrator_sns_publish" -> local.orchestrator_role_name
  optional glue:GetTable if not present

module.airflow_ec2:
  updated files/bootstrap.sh (+ requirements handling)
  identity module: NO CHANGE

output "airflow_variables_map":
  map of lab_* keys from module outputs (lambda, glue, ecs, athena, sns, ...)
```

## Airflow Variables Contract (from `airflow_variables_map`)

Suggested keys (must match FD):

| Key | Source output / value |
|---|---|
| `lab_lambda_function_name` | U3 lambda name |
| `lab_glue_job_name` | U3 glue job |
| `lab_ecs_cluster` | U3 cluster name/ARN |
| `lab_ecs_task_definition` | U3 task def |
| `lab_ecs_subnets` | private subnet ids CSV |
| `lab_ecs_security_groups` | ECS SG id |
| `lab_athena_workgroup` | U2 workgroup |
| `lab_glue_database` | U2 Glue DB |
| `lab_sns_topic_arn` | U4 SNS ARN |
| `lab_athena_output_s3` | s3://athena-results... |
| `lab_e2e_enable_select` | default `"false"` (operator may set) |
| `lab_e2e_schedule` | default `""` |
| `lab_airflow_ui_base` | from `airflow_ui_url` / public IP |

## Rollback

| Action | Effect |
|---|---|
| Remove SNS module / destroy topic | Stops notify; DAG publish fails until vars updated |
| Detach SNS IAM policy | Publish denied |
| Revert bootstrap | Provider may missing until reinstall |
| Restore `placeholder_smoke.py` from git | Old smoke DAG (optional emergency) |

## Non-Goals
- New VPC / NAT / endpoints
- Wire U1 CW alarm to SNS
- Change `airflow_ec2_identity` module internals
- Separate Terraform workspace
