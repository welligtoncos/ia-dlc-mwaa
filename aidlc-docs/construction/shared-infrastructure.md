# Shared Infrastructure

**Scope**: Recursos provisionados principalmente em **U1 Foundation** e consumidos por U2–U4.

## Shared Resources

| Resource | Owner unit | Consumers |
|---|---|---|
| VPC + subnets + NAT + S3 Gateway Endpoint | U1 | U3 (ECS tasks in private subnets), U1 MWAA |
| MWAA Security Group | U1 | U1 MWAA; possibly referenced by U3 task SG rules |
| Artifact S3 bucket | U1 | U1 MWAA; U4 `s3 sync` |
| MWAA Environment | U1 | U4 DAG runtime |
| MWAA Execution Role | U1 | U2/U3/U4 attach additional least-privilege policies |
| Default tags / name prefix / region var | Root | All units |
| `policies/terraform-apply-policy.json` | U1 (authored) | Operator for whole platform apply |

## Non-Shared (unit-local examples)
| Resource | Unit |
|---|---|
| Data lake bucket / LF / Athena | U2 |
| Lambda / Glue Job / ECS cluster | U3 |
| SNS topic / DAG code | U4 |

## Contract for Downstream Units
Downstream modules **must not** recreate VPC/MWAA/artifact bucket. They consume outputs:

```text
vpc_id
private_subnet_ids
mwaa_security_group_id
artifact_bucket_name / arn
mwaa_environment_name / arn
mwaa_execution_role_arn
aws_region
name_prefix
```

## Change Control
- Breaking changes to shared network/MWAA require coordinated update of U2–U4 IAM and DAG configs.
- Prefer additive IAM policies on the execution role over replacing the role.
