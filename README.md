# ia-dlc-mwaa

Laboratório IaC: plataforma de dados AWS orquestrada por **Amazon MWAA**, com data lake, Lake Formation, Glue, Athena e executors de compute.

## Estado atual (U1 + U2 + U3)

### U1 — Foundation
- VPC (`10.10.0.0/16`), 1 NAT, 2 subnets privadas, SG MWAA
- **S3 Gateway VPC Endpoint**
- Bucket de artefatos Airflow (versioning + BPA + SSE-S3)
- IAM execution role (least privilege base)
- Ambiente MWAA `mw1.small` (Airflow default `2.11.2`, UI **PUBLIC_ONLY**)

### U2 — Data Lake and Governance
- Buckets data + athena-results (BPA, SSE-S3, deny HTTP, results lifecycle 7d)
- Glue Database + crawlers raw/processed (on-demand)
- Lake Formation tags/grants; Athena workgroup enforce
- `scripts/seed-sample.sh`

### U3 — Compute Executors
- Lambda `{prefix}lambda-marker` (Python 3.12, marker em `raw/dt=`)
- Glue Job `{prefix}glue-passthrough` (Glue 4.0, G.1X×2, script no artifact bucket)
- ECS Fargate task (sem Service) — marker via AWS CLI; subnets privadas
- Policy aditiva MWAA (Invoke / StartJobRun / RunTask / PassRole)
- `scripts/smoke-compute.sh`

## Avisos de segurança / custo

- UI MWAA **PUBLIC_ONLY** é decisão de PoC — não use assim em produção.
- **1 NAT** é SPOF consciente (custo); ECS Fargate depende do NAT para pull/API.
- State Terraform é **local** — faça backup do `terraform.tfstate`.
- **Lake Formation Data Lake administrator** deve existir na conta **antes** do apply U2.

## Pré-requisitos

1. Terraform `>= 1.5`
2. AWS CLI v2 (`aws sts get-caller-identity`)
3. Permissões ≈ `policies/terraform-apply-policy.json`
4. LF admins configurados (U2)

## Apply

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

Ou: `bash scripts/apply.sh`

## U2 — seed / crawler / Athena

```bash
bash scripts/seed-sample.sh
aws glue start-crawler --name "$(terraform -chdir=terraform output -raw raw_crawler_name)"
```

## U3 — smoke compute

```bash
bash scripts/smoke-compute.sh
```

Exemplos manuais:

```bash
# Lambda
aws lambda invoke --function-name "$(terraform -chdir=terraform output -raw lambda_function_name)" \
  --payload '{"source":"cli"}' --cli-binary-format raw-in-base64-out out.json

# Glue
aws glue start-job-run --job-name "$(terraform -chdir=terraform output -raw glue_job_name)"

# ECS (preencha subnets/SG via outputs)
aws ecs run-task \
  --cluster "$(terraform -chdir=terraform output -raw ecs_cluster_name)" \
  --launch-type FARGATE \
  --task-definition "$(terraform -chdir=terraform output -raw ecs_task_definition_arn)" \
  --network-configuration "awsvpcConfiguration={subnets=[subnet-a,subnet-b],securityGroups=[sg-x],assignPublicIp=DISABLED}"
```

**PassRole**: a execution role MWAA só pode passar as roles Glue/ECS U3 (least privilege).

## Sync de DAGs (U4)

```bash
bash scripts/sync-dags.sh
```

## Destroy

```bash
cd terraform && terraform destroy
```

## Estrutura

```text
terraform/modules/{network,artifact_store,identity,mwaa,data_lake,glue_catalog,lake_formation,athena,lambda_executor,glue_job,ecs_executor}/
src/lambda_marker/   # handler.py
src/glue/            # glue_passthrough.py
scripts/             # apply, sync-dags, seed-sample, smoke-compute
samples/
dags/                # U4
aidlc-docs/
```
