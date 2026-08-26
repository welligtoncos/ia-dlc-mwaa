# U4-orchestration-notify — Business Rules

## BR-DAG — Pipeline identity

| ID | Rule |
|---|---|
| BR-DAG-01 | DAG id = `lab_pipeline_e2e`; arquivo `dags/lab_pipeline_e2e.py`. |
| BR-DAG-02 | Remover `placeholder_smoke` do repo (não coexistir na UI). |
| BR-DAG-03 | `catchup=False` sempre. |
| BR-DAG-04 | Re-trigger manual permitido a qualquer momento; sem gate de “já running”. |

## BR-SCHED — Schedule policy

| ID | Rule |
|---|---|
| BR-SCHED-01 | Variable `lab_e2e_schedule` ausente ou string vazia → `schedule=None`. |
| BR-SCHED-02 | Variable com valor válido (cron ou preset Airflow) → usar como schedule. |
| BR-SCHED-03 | Schedule agressivo (ex. a cada minuto) **fora** do escopo de lab; operador responsável se definir. |

## BR-BIND — Resource bindings

| ID | Rule |
|---|---|
| BR-BIND-01 | Todos os recursos U2/U3/SNS resolvidos via **Airflow Variables** (não hardcode como fonte da verdade). |
| BR-BIND-02 | Variables mínimas (nomes sugeridos): `lab_lambda_function_name`, `lab_glue_job_name`, `lab_ecs_cluster`, `lab_ecs_task_definition`, `lab_ecs_subnets`, `lab_ecs_security_groups`, `lab_athena_workgroup`, `lab_glue_database`, `lab_sns_topic_arn`, `lab_athena_output_s3` (se necessário ao operator). |
| BR-BIND-03 | Variable ausente no momento da task → falha explícita da task (mensagem clara) + SNS failed via callback. |
| BR-BIND-04 | Operador popula Variables após `terraform output` (procedimento no lab-guide). |

## BR-GRAPH — Task graph

| ID | Rule |
|---|---|
| BR-GRAPH-01 | Ordem: Lambda → (Glue ∥ ECS) → Athena SHOW → [SELECT?] → SNS success. |
| BR-GRAPH-02 | Glue e ECS iniciam **após** sucesso da Lambda e correm em paralelo. |
| BR-GRAPH-03 | Join estrito: falha em Glue **ou** ECS → falha da run; Athena e SNS sucesso **não** executam. |

## BR-ATH — Athena steps

| ID | Rule |
|---|---|
| BR-ATH-01 | `SHOW TABLES IN <lab_glue_database>` sempre executa após join Glue∥ECS. |
| BR-ATH-02 | Variable `lab_e2e_enable_select`: `true` habilita sensor + SELECT; ausente/`false` → skip SELECT (`select_skipped=true`, `select_executed=false`). |
| BR-ATH-03 | Com SELECT habilitado: sensor de dados **hard** — falha do sensor → falha da run + SNS failed. |
| BR-ATH-04 | Aceite funcional **não** exige SELECT nem seed. |

## BR-NOTIFY — SNS events

| ID | Rule |
|---|---|
| BR-NOTIFY-01 | Sucesso: task final publica JSON **estendido** (mínimo + nomes/ARNs executors + `query_execution_id` Athena quando houver). |
| BR-NOTIFY-02 | Campos sucesso mínimos: `dag_id`, `run_id`, `status=success`, `execution_date`, `select_executed`, `select_skipped`. |
| BR-NOTIFY-03 | Falha: `on_failure_callback` publica `dag_id`, `run_id`, `status=failed`, `failed_task_id`, `exception` truncada. |
| BR-NOTIFY-04 | Se Variable `lab_airflow_ui_base` existir, incluir link textual à UI no payload de falha. |
| BR-NOTIFY-05 | Destino publish = ARN em `lab_sns_topic_arn`. |

## BR-ACCEPT — Done when (functional)

| ID | Rule |
|---|---|
| BR-ACCEPT-01 | Trigger manual completa Lambda + Glue + ECS + SHOW TABLES + SNS success (console ou e-mail). |
| BR-ACCEPT-02 | Falha forçada de uma task gera SNS `status=failed`. |
| BR-ACCEPT-03 | SELECT com seed é demonstração opcional, não gate de aceite. |

## Coverage map

| FR / Story | Rules |
|---|---|
| FR-U4-01 SNS | BR-NOTIFY-* |
| FR-U4-02 DAG E2E | BR-DAG-*, BR-GRAPH-* |
| FR-U4-03 Athena | BR-ATH-* |
| FR-U4-04 IAM | (NFR / Infra — fora deste FD) |
| FR-U4-05 requirements.txt | (NFR — fora deste FD) |
| FR-U4-06 docs | BR-BIND-04 |
| FR-U4-07 build | (Build and Test) |
| US-05 | sync docs + BR-DAG-02 |
| US-06 | BR-GRAPH Lambda |
| US-07 | BR-GRAPH Glue∥ECS |
| US-09 | BR-ATH + BR-NOTIFY |
