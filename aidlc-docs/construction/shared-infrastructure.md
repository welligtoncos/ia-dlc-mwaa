# Shared Infrastructure

**Scope**: Recursos provisionados em **U1 Foundation** e **U2 Data Lake and Governance**, consumidos por U3–U4.

## Shared Resources

| Resource | Owner unit | Consumers |
|---|---|---|
| VPC + subnets + NAT + S3 Gateway Endpoint | U1 | U3 (ECS in private subnets), U1 MWAA |
| MWAA Security Group | U1 | U1 MWAA; possibly U3 task SG rules |
| Artifact S3 bucket | U1 | U1 MWAA; U4 `s3 sync` |
| MWAA Environment | U1 | U4 DAG runtime |
| MWAA Execution Role | U1 | U2/U3/U4 attach additional least-privilege policies |
| Default tags / name prefix / region var | Root | All units |
| `policies/terraform-apply-policy.json` | U1 (authored) | Operator for whole platform apply |
| Data lake S3 bucket (`raw/` / `processed/`) | U2 | U3 writers; U4 DAG / Athena |
| Athena results S3 bucket | U2 | U4 Athena tasks |
| Glue Database `{prefix}_lake` | U2 | U3, U4 |
| Glue Crawlers (raw / processed) | U2 | U4 (start crawler tasks) |
| Glue service IAM role | U2 | Crawlers; reference for U3 patterns |
| Lake Formation tags + location + grants | U2 | U3/U4 principals; MWAA role |
| Athena workgroup | U2 | U4 |

## Non-Shared (unit-local examples)
| Resource | Unit |
|---|---|
| Lambda / Glue Job / ECS cluster | U3 |
| SNS topic / DAG code | U4 |

## Contract for Downstream Units
Downstream modules **must not** recreate VPC/MWAA/artifact bucket **or** the U2 lake/catalog/LF/Athena baseline. They consume outputs:

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
```

## Change Control
- Breaking changes to shared network/MWAA/lake require coordinated update of U3–U4 IAM and DAG configs.
- Prefer additive IAM/LF grants on the MWAA execution role over replacing the role.
- LF Data Lake administrator remains a **manual account prerequisite** (not Terraform-owned in this PoC).
