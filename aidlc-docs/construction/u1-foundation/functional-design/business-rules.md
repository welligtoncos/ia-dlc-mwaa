# U1 Foundation — Business Rules

## BR-NET — Network

| ID | Rule |
|---|---|
| BR-NET-01 | Devem existir exatamente **2 subnets privadas** em AZs distintas para MWAA. |
| BR-NET-02 | Deve existir **1 subnet pública** hospedando **1 NAT Gateway** (PoC / custo). |
| BR-NET-03 | Rotas privadas apontam para NAT; pública para IGW. |
| BR-NET-04 | Security group do MWAA aplica regras mínimas AWS (incl. self-reference conforme guia). |
| BR-NET-05 | DNS hostnames e DNS support da VPC devem estar habilitados. |

## BR-ART — Artifact Bucket

| ID | Rule |
|---|---|
| BR-ART-01 | Bucket é **dedicado** a artefatos Airflow (não compartilha data lake). |
| BR-ART-02 | Versionamento **obrigatório**. |
| BR-ART-03 | Block Public Access **total** obrigatório. |
| BR-ART-04 | Provisionamento **não** faz upload de DAGs/plugins/requirements (US-05/U4). |
| BR-ART-05 | Estrutura lógica: `dags/`, `plugins/`, `requirements.txt` (ou path MWAA documentado). |

## BR-MWAA — Environment Acceptance (US-02)

| ID | Rule |
|---|---|
| BR-MWAA-01 | `environment_class` = `mw1.small`. |
| BR-MWAA-02 | `airflow_version` default = `2.11.2` (override por variável se conta não tiver a versão). |
| BR-MWAA-03 | `webserver_access_mode` = `PUBLIC` (PoC consciente). |
| BR-MWAA-04 | Critério de pronto = status **AVAILABLE** (sem exigir smoke HTTP 200). |
| BR-MWAA-05 | Logging CloudWatch habilitado para scheduler, webserver, worker e DAG processing. |
| BR-MWAA-06 | Lifecycle deve ignorar mudanças de `requirements_s3_object_version` e `plugins_s3_object_version`. |

## BR-IAM — Identity & Apply (US-04, US-10 base)

| ID | Rule |
|---|---|
| BR-IAM-01 | Proibido `Action="*"` e `AdministratorAccess` em roles/policies do stack. |
| BR-IAM-02 | Execution role MWAA U1: permissões base a ArtifactBucket + logs (+ KMS se usado). |
| BR-IAM-03 | Documento `policies/terraform-apply-policy.json` cobre **U1–U4** desde o início (um apply). |
| BR-IAM-04 | Toda permissão no apply-policy deve ter comentário do “porquê”. |

## BR-NAME — Naming & Tags

| ID | Rule |
|---|---|
| BR-NAME-01 | Nomes usam prefixo `{project}-{env}-` (ex.: `ia-dlc-mwaa-dev-`). |
| BR-NAME-02 | Tags obrigatórias em recursos: `Project`, `Environment`, `ManagedBy=terraform`. |

## BR-ERR — Errors & Rollback

| ID | Rule |
|---|---|
| BR-ERR-01 | Falha em qualquer passo do fluxo U1 → aborta apply; sem compensação automática. |
| BR-ERR-02 | Runbook mínimo deve documentar `terraform destroy` full e orientação de destroy parcial. |

## Story Coverage

| Story | Rules |
|---|---|
| US-01 | BR-NET-* |
| US-02 | BR-MWAA-* |
| US-03 | BR-ART-* |
| US-04 | BR-IAM-03, BR-IAM-04 |
| US-10 (base) | BR-IAM-01, BR-IAM-02 |
