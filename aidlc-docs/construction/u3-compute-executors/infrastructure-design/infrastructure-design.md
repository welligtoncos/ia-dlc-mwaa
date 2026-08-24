# U3 Compute Executors — Infrastructure Design

## Cloud Context
| Item | Value |
|---|---|
| Provider | AWS |
| Region | Same root var `aws_region` (default `us-east-1`) |
| Environment | `dev` |
| Account | Same as U1/U2 |
| IaC | Same Terraform root; add modules under `terraform/modules/` |

## Logical → AWS Resource Map

| Logical component | AWS resources (Terraform) |
|---|---|
| ServerlessRuntime | `aws_lambda_function` `{prefix}lambda-marker` + role + log group |
| EtlRuntime | `aws_glue_job` `{prefix}glue-passthrough` + role + script object on U1 artifact bucket |
| ContainerRuntime | ECS cluster `{prefix}ecs-cluster`, task definition Fargate, exec+task roles, SG |
| CostGuardrail | Vars sizing (Lambda memory, Glue G.1X×2, Fargate 256/512) |
| OperatorTooling | README U3 + `scripts/smoke-compute.sh` |
| MwaaInvokeGateway | Additive IAM on U1 MWAA execution role |
| Messaging | **N/A in U3** (SNS/SQS → U4) |
| New storage | **None** (lake U2 + artifact U1) |
| New VPC/endpoints | **None** |

## Compute Specification

### Lambda
| Spec | Value |
|---|---|
| Name | `{name_prefix}lambda-marker` |
| Runtime | Python 3.12 |
| Package | Zip via `archive_file` / local source under `src/lambda_marker/` |
| Memory | 128–256 MB (var) |
| Timeout | 60 s |
| VPC | **None** |
| Behavior | PutObject marker → `s3://{data_lake}/raw/dt=YYYY-MM-DD/lambda_marker.json` |

### Glue Job
| Spec | Value |
|---|---|
| Name | `{name_prefix}glue-passthrough` |
| Glue version | 4.0 (Spark) |
| Worker | G.1X × 2 (vars) |
| Script | `s3://{artifact_bucket}/scripts/glue_passthrough.py` |
| I/O | Read `raw/`; write Parquet `processed/dt=YYYY-MM-DD/` |
| Schedule | None (on-demand / MWAA) |

### ECS Fargate
| Spec | Value |
|---|---|
| Cluster | `{name_prefix}ecs-cluster` |
| Launch type | FARGATE |
| Service | **None** (RunTask only) |
| CPU / Memory | 256 / 512 (vars) |
| Image | Public (e.g. `amazon/aws-cli`) |
| Network | U1 private subnets; `assign_public_ip = DISABLED` |
| SG | Dedicated egress SG |
| Behavior | AWS CLI PutObject marker on lake |

## Storage Specification
- No new buckets.
- Glue script uploaded to U1 artifact bucket prefix `scripts/`.
- All data I/O against U2 data lake bucket paths.

## Network Specification
- Reuse U1 VPC, private subnets, NAT, S3 gateway endpoint.
- Lambda not attached to VPC.
- No ALB, API Gateway, or new interface VPC endpoints.

## Monitoring Specification
- CloudWatch Log Groups for Lambda and ECS (retention 14–30 days).
- Glue continuous/job logs via service defaults.
- No dashboards or alarms in U3.

## IAM Specification (summary)
| Principal | Trust | Key access |
|---|---|---|
| Lambda role | `lambda.amazonaws.com` | S3 Put/Get on lake `raw/`; CW logs |
| Glue role | `glue.amazonaws.com` | S3 raw read + processed write; Get script on artifact; Catalog minimal |
| ECS execution role | `ecs-tasks.amazonaws.com` | Pull image logs; CW |
| ECS task role | `ecs-tasks.amazonaws.com` | S3 Put marker on lake |
| MWAA execution (additive) | (existing) | Invoke Lambda; StartJobRun+Get*; RunTask+Describe/Stop; PassRole to Glue/ECS roles |

## Module Layout (Code Generation target)

```
terraform/modules/lambda_executor/
terraform/modules/glue_job/
terraform/modules/ecs_executor/
terraform/main.tf          # wire + MWAA policy
src/lambda_marker/         # handler
src/glue/glue_passthrough.py
scripts/smoke-compute.sh
```

## Out of Scope (U3)
ECS Service always-on, Lambda-in-VPC, DLQ/SQS, SNS alarms, ECR, new buckets, Interface Endpoints, DAG orchestration.
