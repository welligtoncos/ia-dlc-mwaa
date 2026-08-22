# ia-dlc-mwaa

Laboratório IaC: plataforma de dados AWS orquestrada por **Amazon MWAA**, com data lake/governança e executors (em unidades seguintes).

## Estado atual (U1 Foundation)

Provisiona:
- VPC (`10.10.0.0/16`), 1 NAT, 2 subnets privadas, SG MWAA
- **S3 Gateway VPC Endpoint**
- Bucket de artefatos Airflow (versioning + BPA + SSE-S3)
- IAM execution role (least privilege base)
- Ambiente MWAA `mw1.small` (Airflow default `2.11.2`, UI **PUBLIC**)

## Avisos de segurança / custo

- UI MWAA **PUBLIC** é decisão de PoC — não use assim em produção.
- **1 NAT** é SPOF consciente (custo).
- State Terraform é **local** — faça backup do `terraform.tfstate`.
- Headroom futuro documentado: `mw1.medium` / 2 NAT (não implementado).

## Pré-requisitos

1. Terraform `>= 1.5`
2. AWS CLI v2 com credenciais válidas (`aws sts get-caller-identity`)
3. Permissões do operador ≈ `policies/terraform-apply-policy.json`
4. Checklist IAM: `aidlc-docs/construction/u1-foundation/code/iam-review-checklist.md`
5. Service quota MWAA na região

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

## Sync de DAGs (após U4 / quando houver conteúdo em `dags/`)

```bash
bash scripts/sync-dags.sh
```

## Destroy

```bash
cd terraform
terraform destroy
```

## Estrutura

```text
terraform/           # root + modules U1
policies/            # IAM do terraform apply
scripts/             # apply.sh, sync-dags.sh
dags/                # DAGs (U4)
aidlc-docs/          # documentação AI-DLC
```
