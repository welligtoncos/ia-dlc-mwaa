# U2 Data Lake and Governance — Code Generation Plan

**Unidade**: U2 Data Lake and Governance  
**Tipo**: IaC (Terraform modules) — extensão do root U1  
**Workspace root**: `d:\projetos-ia-aws\ia-dlc-mwaa`  
**Código**: NUNCA em `aidlc-docs/`  
**Docs de código**: `aidlc-docs/construction/u2-data-lake-governance/code/`

**Histórias / FR cobertos**: lake S3, Glue catalog/crawlers, Lake Formation tags/grants, Athena workgroup, grants MWAA (base US-07/US-08/US-09)  
**Dependências**: U1 outputs (`name_prefix`, `mwaa_execution_role_arn`, region)  
**Consumidores**: U3 (data bucket / DB), U4 (crawlers, Athena, grants)

Este plano é a **única fonte da verdade** para a Geração de Código da U2.

---

## Contexto

| Item | Valor |
|---|---|
| Layout | Extender `terraform/` + 4 modules novos + `scripts/seed-sample.sh` + README |
| State | Local (mesmo root) |
| Buckets | `{prefix}data-*` + `{prefix}athena-results-*` (random suffix) |
| Glue DB | `{prefix}_lake` (underscores) |
| Crawlers | `{prefix}raw-crawler` / `{prefix}processed-crawler` |
| LF | Tags Classification/Project; admin = prereq manual |
| Athena | Workgroup enforce → results bucket; lifecycle 7d |
| Segurança | BPA + SSE-S3 + deny SecureTransport |
| Hive | Seed em `raw/dt=YYYY-MM-DD/` |

---

## Etapas de geração (Part 2)

### Etapa 1 — Module `data_lake`
- [x] Criar `terraform/modules/data_lake/` (`main.tf`)
- [x] Buckets data + athena-results: versioning (data), BPA, SSE-S3, public access block
- [x] Bucket policies deny `aws:SecureTransport = false`
- [x] Lifecycle expire 7 days no results bucket
- [x] Outputs: names/arns

### Etapa 2 — Module `glue_catalog`
- [x] Criar `terraform/modules/glue_catalog/`
- [x] IAM role Glue service (least privilege S3 data prefixes + catalog)
- [x] Glue Database sanitizado
- [x] Crawlers raw → `s3://data/raw/` e processed → `s3://data/processed/` (sem schedule)
- [x] Outputs: database name, crawler names, role ARN

### Etapa 3 — Module `lake_formation`
- [x] Criar `terraform/modules/lake_formation/`
- [x] Register data lake S3 location
- [x] LF-Tags: `Classification` {raw, processed}, `Project` {ia-dlc-mwaa}
- [x] Associar tags / permissions (database + location)
- [x] Grants a Glue role e MWAA execution role
- [x] Documentar: falha se LF admin não configurado

### Etapa 4 — Module `athena`
- [x] Criar `terraform/modules/athena/`
- [x] Workgroup com enforce e output no results bucket
- [x] Outputs: workgroup name/arn

### Etapa 5 — Root wiring
- [x] Atualizar `terraform/main.tf`: modules data_lake → glue_catalog → lake_formation → athena
- [x] Passar execution role para grants U2
- [x] Vars `glue_database_name` / `athena_workgroup_name` opcionais
- [x] Estender `terraform/outputs.tf`
- [x] `aws_iam_role_policy` lake access na execution role (sem Action `"*"`)

### Etapa 6 — Operator tooling
- [x] `scripts/seed-sample.sh` — upload CSV com retry/backoff
- [x] Sample CSV em `samples/orders_sample.csv`
- [x] Atualizar `README.md` seção U2
- [x] Revisar `policies/terraform-apply-policy.json` (Sid U2)

### Etapa 7 — Docs de código (aidlc-docs)
- [x] `aidlc-docs/construction/u2-data-lake-governance/code/code-generation-summary.md`
- [x] Atualizar `shared-infrastructure.md`

### Etapa 8 — Validação local
- [x] `terraform fmt`
- [x] `terraform validate` — **Success**

---

## Fora do escopo desta geração
- Glue Jobs / Lambda / ECS (U3)
- SNS / DAGs (U4)
- Crawler `schedule`
- Bootstrap automático de LF admin
- Remote state

---

## Aprovação

**Status**: plano aprovado e Parte 2 executada — aguardando aprovação do código gerado (2 opções padrão).
