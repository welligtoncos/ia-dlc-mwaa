# Requirements — U4 Orchestration and Notify

## Intent Analysis Summary

| Field | Value |
|---|---|
| **User request** | Completar U4: DAG E2E (Lambda → Glue ∥ ECS → Athena → SNS), módulo SNS Terraform, IAM do orquestrador EC2, `requirements.txt`, docs de sync/smoke |
| **Request type** | Nova funcionalidade / fechamento do lab E2E |
| **Scope estimate** | Múltiplos componentes (`modules/sns`, IAM EC2, `dags/`, `requirements.txt`, README/lab-guide) |
| **Complexity** | Moderada |
| **Requirements depth** | Padrão |
| **Depends on** | U1 EC2 Airflow, U2 lake/Athena, U3 Lambda/Glue/ECS |
| **Region / Environment** | `us-east-1` / `dev` (inalterado) |

## Decisions Locked (from Q&A)

| Topic | Decision |
|---|---|
| Security Baseline extension | **Disabled** — least privilege do stack permanece; regras SECURITY não bloqueantes |
| DAG layout | **Substituir** `placeholder_smoke.py` por único DAG `lab_pipeline_e2e.py` |
| Task graph | **Paralelo após Lambda**: Glue ∥ ECS → Athena → SNS |
| Trigger | **Manual** + schedule opcional via **variável Airflow** |
| Athena | **SHOW TABLES** sempre + **SELECT** opcional com sensor de dados |
| SNS | Tópico TF + subscription e-mail **opcional** (`sns_notification_email`; vazio = sem subscription) |
| Notify pattern | Task final sucesso (JSON: dag_id, run_id, status) + `on_failure_callback` nas tasks |
| IAM EC2 | `sns:Publish` no tópico U4 + Athena mínimo + `glue:GetTable` / `athena:GetWorkGroup` se operators exigirem |
| Python deps | `apache-airflow-providers-amazon` (compatível Airflow 2.11.2) |
| Docs | README + `docs/lab-guide.md` com fluxo E2E completo |

## Relationship to Baseline / Stories

| Artefato | Relação |
|---|---|
| FR-11 SNS, FR-14 DAG (requirements.md global) | Implementados nesta unidade |
| US-05 sync, US-06 Lambda, US-07 Glue/ECS, US-09 Athena+SNS | Cobertura de aceitação U4 |
| App Design `NotifyService` / `PipelineApp` | Módulo `modules/sns` + código em `dags/` |
| Orquestrador | EC2 Airflow (`orchestrator_mode=ec2`); não MWAA |

## Functional Requirements

### FR-U4-01 — Módulo SNS (`NotifyService`)
- Provisionar tópico SNS dedicado ao status do DAG do lab.
- Variável Terraform `sns_notification_email` (string, default `""`).
- Se e-mail não vazio: criar subscription e-mail no tópico (confirmação AWS permanece manual no inbox).
- Se vazio: apenas tópico; operador valida Publish via console SNS / CloudWatch.
- Output: `sns_topic_arn` (e nome) para wiring IAM e DAG.

### FR-U4-02 — DAG E2E (`PipelineApp`)
- Remover `dags/placeholder_smoke.py`.
- Adicionar `dags/lab_pipeline_e2e.py` com grafo:
  1. `task_invoke_lambda`
  2. Em paralelo: `task_start_glue_job` ∥ `task_run_ecs_fargate`
  3. Após ambos: `task_athena_show_tables` (obrigatório)
  4. Opcional: sensor de dados + `task_athena_select` (quando seed/crawler disponíveis)
  5. `task_publish_sns` de sucesso com payload JSON (`dag_id`, `run_id`, `status`, timestamps úteis)
- `on_failure_callback` publica falha no mesmo tópico SNS (contexto da task/run).
- Trigger: `schedule=None` por default; schedule opcional lido de Variable Airflow (ex.: `lab_e2e_schedule`) quando definida.
- Nomes de recursos (Lambda, Glue job, ECS cluster/task def, Athena workgroup/DB, SNS ARN) via Variables Airflow ou env — alinhados aos outputs Terraform documentados.

### FR-U4-03 — Athena no DAG
- Task obrigatória: `SHOW TABLES IN <glue_database>` no workgroup U2.
- Task opcional: `SELECT` em tabela seed (`seed-sample.sh` + crawler); precedida de sensor/check que falha de forma observável se dados ausentes (não bloqueia o caminho mínimo SHOW TABLES → SNS se a branch opcional for pulável — documentar padrão escolhido no design: branch opcional vs fail-soft).

### FR-U4-04 — IAM orquestrador EC2
- Estender role `airflow-ec2-execution` (ou policies anexas) com:
  - `sns:Publish` somente no ARN do tópico U4
  - Athena: `StartQueryExecution`, `GetQueryExecution`, `GetQueryResults`, `StopQueryExecution` (escopo workgroup/output prefix existentes)
  - `athena:GetWorkGroup` e `glue:GetTable` quando exigidos pelos operators Amazon
- Sem `Action="*"`; sem AdministratorAccess.
- Permissões U3 (Lambda invoke, Glue start/get, ECS RunTask/Describe) já existentes devem permanecer válidas.

### FR-U4-05 — Dependências Python
- `requirements.txt` na raiz (ou path já usado pelo sync de artefatos) com `apache-airflow-providers-amazon` pinado/compatível com Airflow **2.11.2**.
- Documentar como o stack EC2 aplica requirements (compose/bootstrap existente ou extensão mínima documentada).

### FR-U4-06 — Sync e documentação operacional
- Manter sync via `scripts/sync-dags.ps1` / `.sh` → bucket → timer EC2.
- Atualizar **README** e **`docs/lab-guide.md`** com fluxo:
  1. Start EC2 / status UI
  2. Sync DAGs (+ requirements se aplicável)
  3. (Opcional) seed + crawler + smoke-compute
  4. Trigger `lab_pipeline_e2e` na UI
  5. Verificar Athena results / SNS (console ou e-mail se inscrito)
  6. Stop EC2 ao encerrar sessão

### FR-U4-07 — Build / validação
- `terraform fmt` / `validate` / `plan` após módulo SNS + IAM.
- Instruções E2E atualizadas em build-and-test (ou lab-guide) cobrindo DAG completo.

## Non-Functional Requirements

### NFR-U4-01 — Segurança / least privilege
- Policies escopadas a ARNs do projeto.
- UI Airflow continua restrita a `operator_cidr`.
- Subscription e-mail opcional; sem abrir SNS a públicos.

### NFR-U4-02 — Custo / lab
- SNS e queries Athena de exemplo com volume mínimo.
- Sem schedule agressivo por default (manual; schedule só se Variable definida).
- Stop EC2 permanece prática obrigatória no guia.

### NFR-U4-03 — Observabilidade
- Mensagens SNS com identificação clara da run.
- Falhas de task observáveis na UI Airflow + callback SNS.
- Logs CloudWatch dos executors U3 inalterados como fonte de detalhe.

### NFR-U4-04 — Compatibilidade
- Airflow **2.11.2** + LocalExecutor no Compose existente.
- Providers Amazon alinhados à major/minor do Airflow.

## Out of Scope (U4)

- MWAA gerenciado / troca de `orchestrator_mode`.
- Novos executors além dos U3 já provisionados.
- Lake Formation redesign; apenas uso do Catalog/workgroup existentes.
- Alarmas CloudWatch → SNS (opcional futuro; não obrigatório nesta unidade).
- Confirmação automática de subscription e-mail (fluxo AWS manual).

## Acceptance Criteria (Done when)

1. `terraform apply` cria tópico SNS (+ subscription se e-mail informado).
2. Role EC2 consegue Publish SNS e queries Athena mínimas (+ GetTable/GetWorkGroup se necessário).
3. Após sync, UI Airflow mostra apenas o DAG E2E `lab_pipeline_e2e` (placeholder removido).
4. Trigger manual executa: Lambda → (Glue ∥ ECS) → Athena SHOW TABLES → SNS sucesso (com seed: branch SELECT opcional).
5. Falha intencional de uma task gera notificação SNS via callback.
6. README + lab-guide documentam o fluxo E2E completo.

## Extension Configuration Impact

| Extension | Enabled | Notes |
|---|---|---|
| Security Baseline | **No** | Opt-out na Q1; least privilege FR/NFR mantidos |
