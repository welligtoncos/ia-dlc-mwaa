# U1 Foundation — Infrastructure Design

## Cloud Context
| Item | Value |
|---|---|
| Provider | AWS |
| Region | Variable `aws_region` (default `us-east-1`) |
| Environment | `dev` |
| Account | Single account PoC |
| IaC | Terraform root + modules under `terraform/` |

## Logical → AWS Resource Map

| Logical component | AWS resources (Terraform) |
|---|---|
| NetworkCapability | VPC, IGW, 1 EIP+NAT, 3 subnets, 2–3 route tables, SG MWAA, **S3 Gateway VPC Endpoint** |
| ArtifactBucket | S3 bucket + versioning + BPA + SSE-S3 + public access block |
| ExecutionIdentity | IAM role (MWAA service trust) + inline/managed customer policies (least privilege base) |
| AirflowEnvironment | `aws_mwaa_environment` mw1.small, PUBLIC, logging to CW |
| LoggingBaseline | Log groups created/managed by MWAA service |
| ApplyPrincipalPolicy | File `policies/terraform-apply-policy.json` (not an AWS resource) |
| OperatorTooling | `scripts/apply.sh`, `scripts/sync-dags.sh`, README |
| CostGuardrail | Vars defaults: class small, single NAT |
| Messaging | **N/A in U1** (SNS → U4) |

## Network Specification

| Resource | Spec |
|---|---|
| VPC CIDR | `10.10.0.0/16` |
| Public subnet | `10.10.0.0/24` (AZ a) — NAT + IGW route |
| Private subnet A | `10.10.1.0/24` (AZ a) — MWAA |
| Private subnet B | `10.10.2.0/24` (AZ b) — MWAA |
| NAT | 1× in public subnet |
| S3 Endpoint | Gateway type; associated to **private** route tables |
| MWAA SG | Self-referencing ingress as per AWS MWAA guidance; egress as required |

## Compute Specification
- **Only** Amazon MWAA environment:
  - Class: `mw1.small` (var)
  - Airflow: default `2.11.2` (var)
  - Web: `PUBLIC`
  - Source bucket: ArtifactBucket
  - Execution role: ExecutionIdentity
  - Network: 2 private subnets + SG
  - Lifecycle ignore: requirements/plugins object versions

## Storage Specification
- Artifact S3 bucket named with `{project}-{env}-` prefix (+ random suffix if needed for global uniqueness)
- Encryption: SSE-S3
- Versioning: enabled
- BPA: all four settings true
- No DAG objects created by Terraform

## Monitoring Specification
- MWAA → CloudWatch Logs enabled
- Acceptance: environment status `AVAILABLE`
- No CW dashboards / alarms in U1

## IAM Specification (U1 base)
Execution role needs (minimum for U1):
- S3: Get/List/Put on ArtifactBucket prefixes used by MWAA
- Logs: CreateLogStream/PutLogEvents (and related MWAA logging perms)
- Airflow service permissions as required by MWAA execution role docs (scoped, no `*`)
- KMS: only if SSE-KMS introduced later (not default)

Cross-service grants for Lambda/Glue/ECS/Athena/SNS/LF are **U2/U3/U4** attachments on the same role (or additional policies), planned but not all required for U1 bring-up.

## Module Layout (Code Generation target)

```
terraform/
  versions.tf
  providers.tf
  variables.tf
  outputs.tf
  main.tf
  modules/network/
  modules/artifact_store/
  modules/identity/
  modules/mwaa/
policies/terraform-apply-policy.json
scripts/apply.sh
scripts/sync-dags.sh
README.md
```

## Out of Scope (U1)
EC2 bastion, ECS/Lambda/Glue, data lake bucket, Lake Formation, Athena, SNS, interface VPC endpoints.
