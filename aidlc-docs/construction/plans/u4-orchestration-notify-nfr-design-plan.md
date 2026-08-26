# U4-orchestration-notify — NFR Design Plan

**Unidade**: U4 Orchestration and Notify  
**Entrada**: `nfr-requirements.md`, `tech-stack-decisions.md`, FD  
**Saída**: `nfr-design-patterns.md`, `logical-components.md`

Preencha cada `[Answer]:` e avise (`pronto`).

---

## 1. Checklist (após respostas)

- [x] `aidlc-docs/construction/u4-orchestration-notify/nfr-design/nfr-design-patterns.md`
- [x] `aidlc-docs/construction/u4-orchestration-notify/nfr-design/logical-components.md`
- [x] Apresentar para aprovação (2 opções)

---

## 2. Perguntas

### Question 1 — Padrões de resiliência (tasks DAG)

A) `retries=1`, `retry_delay=60s` nas tasks AWS; `execution_timeout` por kind: Lambda 5m, Glue 45m, ECS 30m, Athena 15m, SNS 2m

B) `retries=0` em todas; só timeouts: Lambda 5m, Glue 60m, ECS 45m, Athena 20m, SNS 2m

C) Default Airflow sem timeouts explícitos (não recomendado)

X) Other (please describe after [Answer]: tag below)

[Answer]:A (retries=1 + retry_delay=60s + execution_timeout por tipo de task)

---

### Question 2 — Padrões de escalabilidade

A) Document-only: `max_active_runs=1` no DAG E2E para evitar sobreposição acidental (leve concurrency guard sem fila)

B) Sem `max_active_runs`; operador disciplina manual (NFR-S-01)

X) Other (please describe after [Answer]: tag below)

[Answer]:A (max_active_runs=1 no DAG)

---

### Question 3 — Padrões de desempenho / providers install

A) Instalar amazon provider via **`_PIP_ADDITIONAL_REQUIREMENTS`** no `docker-compose.yml` / env do webserver+scheduler (rebuild/restart documentado)

B) Instalar via **bootstrap** `pip install -r requirements.txt` no volume compartilhado antes do compose up

C) Sync `requirements.txt` para ArtifactStore + timer na EC2 aplica pip periodicamente (mais complexo)

X) Other (please describe after [Answer]: tag below)

[Answer]:B (instalar provider via bootstrap pip install -r requirements.txt no volume)

---

### Question 4 — Padrões de segurança (SNS + IAM)

A) Pattern **dual-control publish**: (1) identity policy no role EC2 `sns:Publish` no ARN do tópico; (2) topic policy `Allow` Publish só desse role ARN; Deny implícito a outros principals da conta sem policy

B) Só identity policy (sem topic policy) — override NFR-SEC-04

C) A + encryption at rest com KMS CMK — override NFR (já rejeitado)

X) Other (please describe after [Answer]: tag below)

[Answer]:A (dual-control: identity policy + topic policy)

---

### Question 5 — Observabilidade lógica

A) **PipelineNotifyChannel** = SNS topic; DAG success task + failure callback; sem métricas custom CloudWatch nesta U4

B) A + CloudWatch metric filter / log metric em falhas do DAG (complexidade extra)

X) Other (please describe after [Answer]: tag below)

[Answer]:A (SNS como canal; sem métricas custom nesta U4)

---

### Question 6 — Componentes lógicos NFR a modelar

A) `NotifyTopic`, `TopicAccessPolicy`, `OrchestratorPublishGrant`, `ProviderRuntime`, `VariableBindingTool`, `PipelineReliabilityPolicy`, `OperatorE2EGuide`

B) Só `NotifyTopic` + `OrchestratorPublishGrant` (mínimo)

X) Other (please describe after [Answer]: tag below)

[Answer]:A (os sete componentes lógicos)

---

### Question 7 — Helper set-airflow-variables (padrão de integração)

A) Script lê `terraform output -json`, mapeia keys conhecidas → Variables; autentica na UI/API Airflow com user/senha do SSM (documentado)

B) Script só imprime `airflow variables set` commands para o operador colar via SSM na EC2 (sem chamar API remota)

X) Other (please describe after [Answer]: tag below)

[Answer]:B (script imprime os comandos airflow variables set para colar via SSM)

---

## 3. Defaults sugeridos (lab)

| Q | Sugestão |
|---|---|
| 1 | A (retries=1 + timeouts) |
| 2 | A (`max_active_runs=1`) |
| 3 | A (`_PIP_ADDITIONAL_REQUIREMENTS`) |
| 4 | A (dual-control) |
| 5 | A |
| 6 | A (componentes completos) |
| 7 | B (commands via SSM — mais simples/seguro no lab) |
