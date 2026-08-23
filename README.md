# ia-dlc-mwaa

Laboratório IaC: plataforma de dados AWS orquestrada por **Amazon MWAA**, com data lake, Lake Formation, Glue e Athena.

## Estado atual (U1 Foundation + U2 Data Lake)

### U1 — Foundation
- VPC (`10.10.0.0/16`), 1 NAT, 2 subnets privadas, SG MWAA
- **S3 Gateway VPC Endpoint**
- Bucket de artefatos Airflow (versioning + BPA + SSE-S3)
- IAM execution role (least privilege base)
- Ambiente MWAA `mw1.small` (Airflow default `2.11.2`, UI **PUBLIC_ONLY**)

### U2 — Data Lake and Governance
- Buckets `{prefix}data-*` e `{prefix}athena-results-*` (BPA, SSE-S3, **deny HTTP**, results lifecycle **7 dias**)
- Glue Database + crawlers **raw** / **processed** (on-demand; sem schedule)
- Lake Formation: register location, LF-Tags `Classification` / `Project`, grants Glue + MWAA
- Athena workgroup com **enforce** → results bucket
- Policy aditiva na execution role MWAA + `scripts/seed-sample.sh`

## Avisos de segurança / custo

- UI MWAA **PUBLIC_ONLY** é decisão de PoC — não use assim em produção.
- **1 NAT** é SPOF consciente (custo).
- State Terraform é **local** — faça backup do `terraform.tfstate`.
- Headroom futuro documentado: `mw1.medium` / 2 NAT; crawler **schedule** (não implementado).
- **Lake Formation Data Lake administrator** deve existir na conta **antes** do apply U2 (manual na console AWS).

## Pré-requisitos

1. Terraform `>= 1.5`
2. AWS CLI v2 com credenciais válidas (`aws sts get-caller-identity`)
3. Permissões do operador ≈ `policies/terraform-apply-policy.json`
4. Checklist IAM: `aidlc-docs/construction/u1-foundation/code/iam-review-checklist.md`
5. Service quota MWAA na região
6. **U2:** configurar Lake Formation admins (console → Lake Formation → Administrative roles and tasks)

## Apply

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

Ou:

```bash
bash scripts/apply.sh
```

Create do MWAA costuma levar **20–40+ minutos**.

## Override de versão Airflow

```bash
terraform apply -var="airflow_version=2.10.3"
```

## U2 — seed, crawler e Athena

```bash
# 1) Upload CSV Hive-style raw/dt=YYYY-MM-DD/
bash scripts/seed-sample.sh

# 2) Disparar crawler raw
aws glue start-crawler --name "$(terraform -chdir=terraform output -raw raw_crawler_name)"

# 3) Consultar no Athena (workgroup enforce)
aws athena start-query-execution \
  --work-group "$(terraform -chdir=terraform output -raw athena_workgroup_name)" \
  --query-string "SHOW TABLES IN $(terraform -chdir=terraform output -raw glue_database_name);"
```

Paths Hive: `s3://<data>/raw/dt=YYYY-MM-DD/...` e `processed/dt=YYYY-MM-DD/...` (writers U3).

## Sync de DAGs (após U4 / quando houver conteúdo em `dags/`)

```bash
bash scripts/sync-dags.sh
```

## Destroy

```bash
cd terraform
terraform destroy
```

Esvazie buckets (data / athena-results / artifacts) se o destroy reclamar de objetos.

## Estrutura

```text
terraform/                 # root + modules U1/U2
  modules/network/
  modules/artifact_store/
  modules/identity/
  modules/mwaa/
  modules/data_lake/
  modules/glue_catalog/
  modules/lake_formation/
  modules/athena/
policies/                  # IAM do terraform apply
scripts/                   # apply.sh, sync-dags.sh, seed-sample.sh
samples/                   # CSV de exemplo (sem PII)
dags/                      # DAGs (U4)
aidlc-docs/                # documentação AI-DLC
```
