# Clarification Questions — U4 Orchestration and Notify

**Unit**: U4 — Orchestration and Notify (DAG E2E + SNS + docs de sync)  
**Contexto**: U1 EC2 Airflow operacional; U2 Data Lake + Athena; U3 Lambda/Glue/ECS provisionados; `placeholder_smoke.py` existe  
**Histórias de referência**: US-05, US-06, US-07, US-09 (Epics E2/E3)  
**Instruções**: Preencha cada `[Answer]:` com a letra (ex.: `A`) ou `X` + descrição. Salve o arquivo e avise no chat.

---

## Question 1 — Extensões de segurança
As regras da extensão **Security Baseline** devem ser aplicadas nesta unidade U4?

A) Sim — aplicar todas as regras SECURITY como restrições bloqueantes

B) Não — pular (adequado para lab/PoC; manter least privilege já acordado no stack)

X) Other (please describe after [Answer]: tag below)

[Answer]:B (pular Security Baseline como bloqueante; least privilege já acordado)

---

## Question 2 — Escopo do DAG E2E
Como tratar o DAG `placeholder_smoke.py` existente?

A) Substituir por um único DAG E2E (`lab_pipeline_e2e.py`) que cobre Lambda → Glue → ECS → Athena → SNS

B) Manter `placeholder_smoke.py` e adicionar `lab_pipeline_e2e.py` separado (dois DAGs na UI)

C) Evoluir `placeholder_smoke.py` in-place para o fluxo E2E completo

X) Other (please describe after [Answer]: tag below)

[Answer]:A (substituir o placeholder por um único DAG E2E lab_pipeline_e2e.py)

---

## Question 3 — Ordem das tasks no DAG
Qual sequência de execução preferida?

A) Linear: Lambda → Glue Job → ECS Fargate → Athena query → SNS publish (sucesso)

B) Paralelo após Lambda: Glue e ECS em paralelo → Athena → SNS

C) Mínimo viável primeiro: Lambda → SNS (demais tasks adicionadas em fase 2)

X) Other (please describe after [Answer]: tag below)

[Answer]:B (paralelo após Lambda: Glue ∥ ECS → Athena → SNS)

---

## Question 4 — Gatilho do DAG
Como o DAG E2E deve ser disparado?

A) Apenas manual (`schedule=None`; operador clica "Trigger" na UI)

B) Schedule diário leve (ex.: `@daily`) com `catchup=False`

C) Manual + botão/documentação; schedule opcional via variável Airflow

X) Other (please describe after [Answer]: tag below)

[Answer]:C (manual + schedule opcional via variável Airflow)


---

## Question 5 — Task Athena
Qual query de exemplo usar (US-09)?

A) `SHOW TABLES IN <glue_database>` — valida Catalog/LF sem depender de dados seed

B) `SELECT` em tabela populada por `seed-sample.sh` + crawler (requer seed prévio documentado)

C) Ambos: task `SHOW TABLES` + task `SELECT` opcional com sensor de dados

X) Other (please describe after [Answer]: tag below)

[Answer]: C (SHOW TABLES sempre + SELECT opcional com sensor de dados)

---

## Question 6 — Tópico SNS e subscription
Como configurar notificações SNS?

A) Tópico SNS via Terraform; **sem** subscription por default (Publish só no lab; operador vê mensagem no console SNS)

B) Tópico SNS + subscription de **e-mail** opcional via variável Terraform `sns_notification_email` (vazio = sem subscription)

C) Tópico SNS + subscription e-mail **obrigatória** (informar e-mail no apply)

X) Other (please describe after [Answer]: tag below)

[Answer]:B (tópico SNS + subscription de e-mail opcional via variável; vazio = sem subscription)

---

## Question 7 — Conteúdo e momento da notificação SNS
Quando e o que publicar no SNS?

A) Task final de sucesso com resumo JSON (dag_id, run_id, status) + `on_failure_callback` em todas as tasks com erro

B) Apenas `on_failure_callback` global (sucesso silencioso)

C) Sucesso e falha sempre via task dedicada `publish_sns` no fim (sem callbacks)

X) Other (please describe after [Answer]: tag below)

[Answer]:A (task final de sucesso com resumo JSON + on_failure_callback nas tasks)

---

## Question 8 — Permissões IAM do orquestrador (EC2 role)
O execution role EC2 já tem permissões U3; para U4 precisamos estender com SNS Publish + Athena. Confirma escopo?

A) Sim — adicionar `sns:Publish` só no tópico U4 + Athena mínimo (`StartQueryExecution`, `GetQueryExecution`, `GetQueryResults`, `StopQueryExecution`) no workgroup/output prefix já existentes

B) Sim, mas incluir também `glue:GetTable` / `athena:GetWorkGroup` se necessário aos operators Airflow

C) Revisar manualmente todas as policies U1–U3 antes de qualquer attach U4

X) Other (please describe after [Answer]: tag below)

[Answer]:B (SNS Publish + Athena mínimo + glue:GetTable/athena:GetWorkGroup que os operators exigem)

---

## Question 9 — `requirements.txt` do Airflow
Quais providers Python incluir para o DAG E2E?

A) Mínimo: `apache-airflow-providers-amazon` (versão compatível com Airflow 2.11.2) — operators AWS nativos

B) Mínimo + `boto3` pin explícito alinhado à imagem Docker

C) Sem `requirements.txt` extra — usar apenas PythonOperator + boto3 já na imagem base

X) Other (please describe after [Answer]: tag below)

[Answer]:A (mínimo: apache-airflow-providers-amazon compatível com 2.11.2)

---

## Question 10 — Documentação de sync e smoke E2E
O que atualizar além do código?

A) README + `docs/lab-guide.md` com fluxo: sync DAGs → trigger E2E → verificar SNS/Athena/S3 results

B) Apenas README na raiz

C) README + novo doc `docs/e2e-pipeline.md` dedicado; lab-guide permanece focado em ligar/desligar EC2

X) Other (please describe after [Answer]: tag below)

[Answer]:A (README + docs/lab-guide.md com o fluxo E2E completo)
