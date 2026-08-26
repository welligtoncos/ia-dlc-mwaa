# U4-orchestration-notify — Code Generation Plan

**Unidade**: U4 Orchestration and Notify (brownfield)  
**Workspace root**: `d:\projetos-ia-aws\ia-dlc-mwaa`  
**Código**: NUNCA em `aidlc-docs/`  
**Docs resumo**: `aidlc-docs/construction/u4-orchestration-notify/code/`

**FRs**: FR-U4-01..07  
**Histórias**: US-05, US-06, US-07, US-09  
**Dependências**: U1 EC2 Airflow, U2 Athena/Glue DB, U3 Lambda/Glue/ECS, `orchestrator_role_arn`  
**Design**: FD + NFR + Infra Design aprovados

Este plano é a **única fonte da verdade** para a Geração de Código desta unidade.

---

## Contexto

| Item | Valor |
|---|---|
| Módulo novo | `terraform/modules/sns` |
| Root alterado | `main.tf`, `variables.tf`, `outputs.tf` |
| Identity module | **intocado** (IAM U4 no root) |
| Bootstrap | `modules/airflow_ec2/files/bootstrap.sh` + S3 upload |
| DAG | `dags/lab_pipeline_e2e.py`; remover `placeholder_smoke.py` |
| Deps | `requirements.txt` (amazon provider pin) |
| Scripts | `set-airflow-variables.ps1` + `.sh` |
| Docs | README + `docs/lab-guide.md` |

---

## Etapas de geração (Part 2)

### Etapa 1 — Módulo Terraform `sns`
- [x] Criar `terraform/modules/sns/main.tf` — topic, optional email subscription, topic policy (Publish só `publisher_role_arn`)
- [x] Criar `variables.tf`, `outputs.tf` (`topic_arn`, `topic_name`)
- [x] Tags + name `{name_prefix}pipeline-status` (ou equivalente)

### Etapa 2 — Root wiring SNS + variables
- [x] `variables.tf`: `sns_notification_email` default `""`
- [x] `main.tf`: `module "sns"` com `publisher_role_arn = local.orchestrator_role_arn`
- [x] `outputs.tf`: `sns_topic_arn`, `sns_topic_name`

### Etapa 3 — IAM U4 no root
- [x] `aws_iam_role_policy` SNS Publish no ARN do tópico → `local.orchestrator_role_name`
- [x] Confirmar Athena/`glue:GetTable` já cobertos por `mwaa_lake_access`; **só** complementar se faltar ação
- [x] Sem `Action="*"`

### Etapa 4 — Output `airflow_variables_map`
- [x] Mapear keys `lab_*` a partir de outputs U2/U3/U4 + UI URL
- [x] Defaults: `lab_e2e_enable_select=false`, `lab_e2e_schedule=""`

### Etapa 5 — ProviderRuntime (bootstrap + requirements)
- [x] Criar `requirements.txt` na raiz: `apache-airflow-providers-amazon` pin compatível 2.11.2
- [x] Upload/sync path: incluir requirements no pacote `airflow-ec2/` (S3 object) **ou** sync documentado
- [x] Atualizar `bootstrap.sh`: `pip install -r requirements.txt` no volume compartilhado antes do `compose up` (como root/host com path montado ou via `docker run --rm` na imagem Airflow)
- [x] Documentar necessidade de re-bootstrap / restart após mudança de requirements

### Etapa 6 — DAG E2E
- [x] Remover `dags/placeholder_smoke.py`
- [x] Criar `dags/lab_pipeline_e2e.py`:
  - `max_active_runs=1`, `catchup=False`, schedule via Variable `lab_e2e_schedule`
  - Lambda → Glue ∥ ECS → Athena SHOW → SELECT se `lab_e2e_enable_select` → SNS success
  - retries=1, retry_delay=60s, timeouts por kind (NFR Design)
  - `on_failure_callback` SNS (payload + UI link se `lab_airflow_ui_base`)
  - Payload sucesso estendido (FD)

### Etapa 7 — Scripts VariableBindingTool
- [x] `scripts/set-airflow-variables.ps1` e `.sh`: ler `terraform output -json airflow_variables_map`, imprimir `airflow variables set ...` (sem API remota)

### Etapa 8 — Documentação operador
- [x] Atualizar `README.md` (seção U4 / E2E)
- [x] Atualizar `docs/lab-guide.md`: apply SNS, sync, set vars via SSM, trigger, verify SNS, custo marginal, RTO start

### Etapa 9 — Validação + resumo
- [x] `terraform fmt` + `terraform validate` no diretório `terraform/`
- [x] Criar `aidlc-docs/construction/u4-orchestration-notify/code/code-generation-summary.md`
- [x] Marcar checkboxes deste plano
- [x] Apresentar gate 2 opções (Solicitar Alterações | Continuar → Build and Test)

---

## Fora de escopo nesta geração
- Wire alarme EC2 → SNS
- Mudanças em `airflow_ec2_identity`
- Novos VPC endpoints
- Build-and-test instructions detalhadas (próximo estágio)

---

## Aprovação

**Approved**: `Aprovar plano de código U4` — Part 2 executed.
