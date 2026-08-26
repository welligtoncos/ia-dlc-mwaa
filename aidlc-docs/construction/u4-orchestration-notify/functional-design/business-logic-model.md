# U4-orchestration-notify — Business Logic Model

## Purpose
Modelar a lógica de orquestração E2E do lab (agnóstica a Terraform): pipeline Airflow que invoca executors U3, consulta Athena U2 e notifica via SNS.

## Primary Flow — Lab Pipeline E2E Run

```
1. Resolve PipelineSchedulePolicy (Variable lab_e2e_schedule → schedule or None)
2. Resolve ResourceBindings from Airflow Variables (operator-populated)
3. Start LabPipelineRun (manual trigger or schedule)
4. ExecutorTask Lambda (invoke)
5. Parallel fork:
     - ExecutorTask Glue (start + wait success)
     - ExecutorTask ECS Fargate (run + wait success)
6. Join: BOTH must succeed (any failure → fail run + NotificationEvent failed)
7. AthenaQueryStep SHOW TABLES (always)
8. IF lab_e2e_enable_select == true:
     - Sensor/check dados seed
     - IF fail → fail run + NotificationEvent failed (hard)
     - IF ok → AthenaQueryStep SELECT
   ELSE:
     - Skip SELECT (select_executed=false; select_skipped=true)
9. NotificationEvent success (extended JSON payload) → SNS Publish
10. End LabPipelineRun success
```

## Failure Path

```
ON any task failure (or hard SELECT path):
  → on_failure_callback publishes NotificationEvent failed
  → downstream success tasks do not run
  → LabPipelineRun status = failed
```

## Capability Behaviors

### PipelineApp (DAG `lab_pipeline_e2e`)
- Substitui `placeholder_smoke`.
- Grafo: Lambda → (Glue ∥ ECS) → Athena SHOW → [SELECT opcional] → SNS success.
- `catchup=False` quando schedule ativo.
- Re-trigger manual livre; sem lock de run concorrente (best-effort nos executors).

### ResourceBinding
- Nomes/ARNs lógicos só via Airflow Variables (não hardcoded no DAG como fonte da verdade).
- Operador preenche após `terraform output` (documentado no lab-guide).

### PipelineSchedulePolicy
- Variable `lab_e2e_schedule` ausente/vazia → `schedule=None` (manual only).
- Valor cron ou preset (`@daily`, …) → schedule com `catchup=False`.

### AthenaQueryStep
- SHOW TABLES sempre (aceite mínimo).
- SELECT controlado por `lab_e2e_enable_select`:
  - `false`/ausente: não sensor, não SELECT.
  - `true`: sensor hard; falha → run failed + SNS failed.

### NotificationEvent
- Sucesso: JSON estendido (dag_id, run_id, status, execution_date, select flags, nomes/ARNs executors, query_execution_id).
- Falha: dag_id, run_id, status=failed, failed_task_id, exception truncada; + `airflow_ui_url` se Variable `lab_airflow_ui_base` existir.

### NotifyService (lógico)
- Destino: tópico SNS do lab (ARN via ResourceBinding).
- Subscription e-mail é concern de infra (não altera lógica do payload).

## Outputs Downstream
| Output | Consumers |
|---|---|
| SNS success/failed message | Operator (console/email) |
| Athena query results | S3 athena-results (U2) |
| LabPipelineRun status | Airflow UI |

## Acceptance Logic (functional)
- Manual trigger: Lambda + Glue + ECS + SHOW TABLES + SNS success.
- Forced task failure → SNS failed.
- SELECT **não** é obrigatório no aceite.
