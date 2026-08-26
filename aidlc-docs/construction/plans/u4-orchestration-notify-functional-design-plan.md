# U4-orchestration-notify — Functional Design Plan

**Unidade**: U4 Orchestration and Notify  
**FRs**: FR-U4-01..07  
**Histórias**: US-05, US-06, US-07, US-09  
**Foco**: lógica de negócio do DAG E2E + NotifyService (agnóstico a detalhes TF até Infrastructure Design)

Preencha cada `[Answer]:` e avise no chat (`pronto`).

---

## 1. Checklist de artefatos (Parte 2 — após respostas)

- [x] `business-logic-model.md`
- [x] `business-rules.md`
- [x] `domain-entities.md`
- [x] Validar cobertura FR-U4-01..07 / US-05..07,US-09
- [x] Apresentar para aprovação (2 opções)

---

## 2. Escopo

**Inclui**: grafo do DAG `lab_pipeline_e2e`, regras de schedule Variable, Athena SHOW/SELECT, payload SNS sucesso/falha, critérios de aceite E2E, contrato lógico com recursos U2/U3.  
**Não inclui**: nomes de resources TF, policies IAM JSON, pin exato de provider (NFR), layout de pastas Compose (já U1).

---

## 3. Perguntas

### Question 1 — Entidades de domínio U4

A) Entidades: `LabPipelineRun`, `ExecutorTask` (Lambda/Glue/ECS), `AthenaQueryStep`, `NotificationEvent`, `PipelineSchedulePolicy`, `ResourceBinding` (nomes/ARNs lógicos)

B) Só checklist de tasks Airflow sem modelo de domínio explícito

X) Other (please describe after [Answer]: tag below)

[Answer]:A (entidades de domínio explícitas)

---

### Question 2 — Branch Athena SELECT opcional

A) **Branch soft**: SHOW TABLES sempre; se sensor de dados falhar, **pular** SELECT e seguir para SNS sucesso (com flag `select_skipped=true` no payload)

B) **Branch hard**: SHOW TABLES sempre; se sensor falhar, **falhar a run** (SNS via `on_failure_callback`); SELECT só roda com seed presente

C) Variable Airflow `lab_e2e_enable_select` (`true`/`false`): se `false`, nem sensor nem SELECT; se `true`, aplica regra B

X) Other (please describe after [Answer]: tag below)

[Answer]:C (Variable lab_e2e_enable_select controla; hard se ligado)

---

### Question 3 — Falha parcial no paralelo Glue ∥ ECS

A) Qualquer falha em Glue **ou** ECS → falha da run (downstream Athena/SNS sucesso não rodam); SNS falha via callback

B) Continuar Athena mesmo se um dos paralelos falhar (não recomendado para lab de aprendizado)

X) Other (please describe after [Answer]: tag below)

[Answer]:A (falha em Glue ou ECS → falha a run; SNS via callback)

---

### Question 4 — Onde residem os ResourceBindings (nomes Lambda, Glue, ECS, Athena, SNS)

A) **Airflow Variables** (ex.: `lab_lambda_function_name`, `lab_glue_job_name`, …) documentadas no lab-guide; operador popula após `terraform output`

B) **Env vars** no Compose Airflow injetadas no bootstrap a partir de outputs TF / SSM

C) Hardcode no DAG com defaults do lab `dev` + override por Variable se existir

X) Other (please describe after [Answer]: tag below)

[Answer]:A (Airflow Variables, populadas após terraform output)

---

### Question 5 — Schedule opcional (`lab_e2e_schedule`)

A) Se Variable **ausente ou vazia** → `schedule=None` (só manual); se valor cron/`@daily` → usa esse schedule com `catchup=False`

B) Sempre `schedule=None`; Variable só documentada para futuro (não lida no código nesta U4)

X) Other (please describe after [Answer]: tag below)

[Answer]:A (Variable ausente/vazia → manual; com cron → usa schedule)

---

### Question 6 — Payload SNS de sucesso

A) JSON mínimo: `dag_id`, `run_id`, `status=success`, `execution_date`, `select_executed` (bool), `select_skipped` (bool opcional)

B) JSON estendido: A + ARNs/nomes dos executors + query_execution_id Athena

X) Other (please describe after [Answer]: tag below)

[Answer]:B (payload estendido: mínimo + ARNs/nomes + query_execution_id)

---

### Question 7 — Payload SNS de falha (`on_failure_callback`)

A) JSON: `dag_id`, `run_id`, `status=failed`, `failed_task_id`, `exception` (mensagem truncada)

B) Igual A + link textual à UI Airflow (`http://<host>:8080/...`) se Variable `lab_airflow_ui_base` existir

X) Other (please describe after [Answer]: tag below)

[Answer]:B (payload de falha + link à UI se lab_airflow_ui_base existir)

---

### Question 8 — Idempotência / re-trigger

A) Re-trigger manual permitido a qualquer momento; sem locks; executors U3 devem ser seguros para reexecução de lab (best-effort)

B) Evitar re-run se última run ainda `running` (sensor/check no início do DAG)

X) Other (please describe after [Answer]: tag below)

[Answer]:A (re-trigger livre; executors best-effort idempotentes)

---

### Question 9 — Critério de aceite funcional U4

A) Trigger manual: Lambda OK + Glue OK + ECS OK + Athena SHOW TABLES OK + SNS sucesso recebido (console ou e-mail); falha forçada de 1 task gera SNS failed

B) Mesmo que A + SELECT com seed obrigatório no aceite (não opcional)

X) Other (please describe after [Answer]: tag below)

[Answer]:A (aceite com SHOW TABLES; SELECT opcional, não obrigatório)

---

## 4. Defaults sugeridos (lab)

| Q | Sugestão |
|---|---|
| 1 | A |
| 2 | C (Variable controla SELECT; hard se ligado) |
| 3 | A |
| 4 | A (Airflow Variables) |
| 5 | A |
| 6 | A (mínimo) |
| 7 | A |
| 8 | A |
| 9 | A |
