# U2 Data Lake and Governance — Infrastructure Design

## Cloud Context
| Item | Value |
|---|---|
| Provider | AWS |
| Region | Same root var `aws_region` (default `us-east-1`) |
| Environment | `dev` |
| Account | Same single account as U1 |
| IaC | Same Terraform root; add modules under `terraform/modules/` |

## Logical → AWS Resource Map

| Logical component | AWS resources (Terraform) |
|---|---|
| DataLakeStore | S3 `{prefix}-data` (+ versioning, BPA, SSE-S3, deny insecure transport) |
| AthenaResultsStore | S3 `{prefix}-athena-results` (+ BPA, SSE-S3, deny insecure transport, lifecycle 7d) |
| CatalogBoundary | Glue Database `{prefix}_lake`; Crawlers `{prefix}-raw-crawler`, `{prefix}-processed-crawler` |
| GlueServiceIdentity | IAM role trusted by `glue.amazonaws.com` + least-privilege S3/Glue/LF/Logs |
| GovernanceBoundary | Lake Formation: register data bucket location; LF-Tags; LF permissions/grants |
| QueryBoundary | Athena Workgroup `dev` (or `{prefix}-dev`) → results bucket; enforce config |
| SecurityBaseline | BPA/SSE/TLS deny on both buckets; LF tags Classification/Project |
| CostGuardrail | Lifecycle expire objects 7 days on results bucket |
| OperatorTooling | README U2 + `scripts/seed-sample.sh` |
| MWAA lake access | Additional IAM/LF grants on U1 `mwaa_execution_role` (additive) |
| Messaging | **N/A in U2** (SNS → U4) |
| Network additions | **None** (reuse U1 VPC + S3 Gateway Endpoint) |

## Storage Specification

| Bucket | Name pattern | Controls |
|---|---|---|
| Data | `{name_prefix}-data` (+ uniqueness suffix if needed) | Versioning, BPA, SSE-S3, deny `SecureTransport=false` |
| Athena results | `{name_prefix}-athena-results` | BPA, SSE-S3, deny HTTP, **lifecycle Expire 7 days** |

Logical prefixes on data bucket:
- `raw/` and `processed/` (crawler targets)
- Hive-style sample keys: `raw/dt=YYYY-MM-DD/sample.csv` (seed script; not TF objects)

## Catalog Specification

| Resource | Spec |
|---|---|
| Glue Database | Name `{name_prefix}_lake` (underscores; Glue-safe) |
| Raw crawler | Target `s3://{data}/raw/`; database above |
| Processed crawler | Target `s3://{data}/processed/` |
| Schedule | **Not set** (on-demand); headroom documented |
| Glue role | Dedicated service role; S3 Get/List on data prefixes; catalog/LF as required |

## Lake Formation Specification

| Item | Spec |
|---|---|
| Prereq | Account Data Lake administrator configured **manually** before apply |
| Resource | Register S3 data lake location (results bucket typically not LF-governed for query results) |
| LF-Tags | Key `Classification` values `raw`,`processed`; Key `Project` value `ia-dlc-mwaa` |
| Grants | Glue crawler role; Athena query principals / workgroup users as designed; **MWAA execution role** for catalog/S3 needed by U4 |

Exact Terraform resource types (`aws_lakeformation_*`) refined in Code Generation within least-privilege bounds.

## Athena Specification

| Item | Spec |
|---|---|
| Workgroup | Named for env (e.g. `{name_prefix}-dev` or `dev` with project tag) |
| Output | `s3://{athena-results}/` |
| Enforce | `enforce_workgroup_configuration = true` |
| Encryption | Align with results bucket SSE-S3 |

## Compute Specification
- **Only** AWS Glue Crawlers (managed, ephemeral workers).
- No EC2, ECS, Lambda, or Glue ETL Job in U2.

## Network Specification
- No new VPC/subnets/endpoints.
- S3 access from MWAA continues via U1 S3 Gateway Endpoint.

## Monitoring Specification
- Native Glue Crawler logs/metrics.
- No CloudWatch dashboards or alarms in U2.
- CloudTrail: account-level if already present (not created by U2).

## Module Layout (Code Generation target)

```
terraform/
  modules/data_lake/
  modules/glue_catalog/
  modules/lake_formation/
  modules/athena/
  main.tf          # wire U2 modules + U1 outputs
  outputs.tf       # extend with lake outputs
scripts/seed-sample.sh
```

## Out of Scope (U2)
Glue Jobs, Lambda, ECS, SNS, interface VPC endpoints, crawler schedules, sample objects via Terraform, LF admin bootstrap automation.
