# Shared Infrastructure

**Scope**: Recursos provisionados em **U1 Foundation**, **U2 Data Lake and Governance** e **U3 Compute Executors**, consumidos por U4.

## Shared Resources

| Resource | Owner unit | Consumers |
|---|---|---|
| VPC + subnets + NAT + S3 Gateway Endpoint | U1 | U3 ECS; U1 MWAA |
| MWAA Security Group | U1 | U1 MWAA; optional U3 SG pairing |
| Artifact S3 bucket | U1 | U1 MWAA; U3 Glue script; U4 `s3 sync` |
| MWAA Environment | U1 | U4 DAG runtime |
| MWAA Execution Role | U1 | U2/U3/U4 additive policies |
| Default tags / name prefix / region var | Root | All units |
| `policies/terraform-apply-policy.json` | U1 (authored) | Operator whole-platform apply |
| Data lake S3 bucket (`raw/` / `processed/`) | U2 | U3 writers; U4 DAG / Athena |
| Athena results S3 bucket | U2 | U4 Athena tasks |
| Glue Database `{prefix}_lake` | U2 | U3, U4 |
| Glue Crawlers (raw / processed) | U2 | U4 |
| Glue crawler service IAM role | U2 | Crawlers |
| Lake Formation tags + location + grants | U2 | U3/U4; MWAA role |
| Athena workgroup | U2 | U4 |
| Lambda `{prefix}lambda-marker` | U3 | U4 DAG invoke |
| Glue Job `{prefix}glue-passthrough` | U3 | U4 DAG start |
| ECS cluster + Fargate task definition | U3 | U4 DAG RunTask |
| Lambda / Glue / ECS IAM roles | U3 | Runtime + MWAA PassRole |

## Non-Shared (unit-local examples)
| Resource | Unit |
|---|---|
| SNS topic / DAG code | U4 |

## Contract for Downstream Units
Downstream modules **must not** recreate VPC/MWAA/artifact/lake/catalog baseline **or** U3 executors. They consume outputs:

```text
# From U1
vpc_id
private_subnet_ids
mwaa_security_group_id
artifact_bucket_name / arn
mwaa_environment_name / arn
mwaa_execution_role_arn
aws_region
name_prefix

# From U2
data_lake_bucket_name / arn
athena_results_bucket_name / arn
glue_database_name
raw_crawler_name
processed_crawler_name
athena_workgroup_name
glue_service_role_arn

# From U3
lambda_function_arn / name
glue_job_name
ecs_cluster_arn
ecs_task_definition_arn
ecs_security_group_id
lambda_role_arn
glue_job_role_arn
ecs_task_role_arn
ecs_execution_role_arn
```

## Change Control
- Breaking changes to shared network/MWAA/lake/compute require coordinated U4 DAG and IAM updates.
- Prefer additive IAM on the MWAA execution role over replacing the role.
- LF Data Lake administrator remains a **manual account prerequisite**.
- U3 ECS depends on U1 NAT for image pulls and AWS API calls (no new interface endpoints in U3).
