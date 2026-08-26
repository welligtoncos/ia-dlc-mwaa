# U4-orchestration-notify — NFR Requirements Plan

**Unidade**: U4 Orchestration and Notify  
**Próximo artefato**: `nfr-requirements.md` + `tech-stack-decisions.md`  
**Contexto**: PoC `dev` / `us-east-1`; Airflow EC2 2.11.2; FD locked (Variables, Glue∥ECS, SNS extended payload); Security Baseline **disabled**

Preencha cada `[Answer]:` e avise (`pronto`).

---

## 1. Checklist (após respostas)

- [x] `aidlc-docs/construction/u4-orchestration-notify/nfr-requirements/nfr-requirements.md`
- [x] `aidlc-docs/construction/u4-orchestration-notify/nfr-requirements/tech-stack-decisions.md`
- [x] Apresentar para aprovação (2 opções)

---

## 2. Perguntas

### Question 1 — Escalabilidade (pipeline E2E)

A) Sem meta de escala: **1 run manual** por sessão de estudo; LocalExecutor na EC2 atual basta

B) Documentar limite soft: evitar > N runs paralelas do DAG E2E (N=1) sem implementar concurrency guards

X) Other (please describe after [Answer]: tag below)

[Answer]:A (sem meta de escala; 1 run manual por sessão)

---

### Question 2 — Desempenho (SLA da run)

A) Sem SLO formal; aceitar duração típica de lab (Lambda/Glue/ECS/Athena em minutos)

B) Soft goal documentado: run E2E completa (sem SELECT) em **< 30 min** em condições normais de lab

X) Other (please describe after [Answer]: tag below)

[Answer]:A (sem SLO formal)

---

### Question 3 — Disponibilidade

A) Best-effort: pipeline depende de EC2 Airflow + serviços U2/U3; sem HA; falha = retry manual

B) Mesmo que A + documentar: se EC2 stopped, E2E indisponível até `airflow-ec2-start` (RTO operacional = tempo de start)

X) Other (please describe after [Answer]: tag below)

[Answer]:B (best-effort + documentar RTO = tempo de start da EC2)

---

### Question 4 — Segurança (SNS + IAM + DAG)

A) Least privilege: `sns:Publish` só no tópico U4; Athena escopado a workgroup/output; sem secrets no código do DAG (só Variables)

B) Mesmo que A + SNS topic policy restringindo Publish ao role EC2 (além da IAM identity policy)

C) Mesmo que B + criptografia SNS com KMS CMK dedicada (custo/complexidade extra lab)

X) Other (please describe after [Answer]: tag below)

[Answer]:B (least privilege + SNS topic policy restringindo Publish à role EC2)

---

### Question 5 — Stack tecnológica (Airflow / providers)

A) `apache-airflow-providers-amazon` pinado a faixa compatível com Airflow **2.11.2**; operators AWS nativos no DAG

B) Mesmo que A + documentar como o Compose EC2 **instala** requirements (bootstrap/`_PIP_ADDITIONAL_REQUIREMENTS`/volume) — escolher mecanismo mínimo no NFR Design

C) Preferir PythonOperator + boto3 da imagem (sem provider package) — override do FR-U4-05

X) Other (please describe after [Answer]: tag below)

[Answer]:B (provider pinado + mecanismo de instalação documentado)

---

### Question 6 — Confiabilidade / retries

A) Retries Airflow padrão baixos: **0–1** retry nas tasks AWS; timeout por task documentado no design NFR (sem circuit breaker)

B) Retries=2 com exponential backoff nas tasks Glue/ECS/Athena; Lambda retry=1

X) Other (please describe after [Answer]: tag below)

[Answer]:A (retries 0–1 nas tasks AWS; timeout por task; sem circuit breaker)

---

### Question 7 — Observabilidade / alertas

A) SNS da pipeline é o canal principal de sucesso/falha; **não** amarrar alarme EC2 status-check ao SNS nesta U4 (alarme U1 permanece)

B) Amarrar alarme CloudWatch EC2 status-check failed → tópico SNS U4 (além das notificações do DAG)

C) Só CloudWatch Logs / UI Airflow; SNS só via tasks do DAG (sem alarmes infra)

X) Other (please describe after [Answer]: tag below)

[Answer]:A (SNS da pipeline como canal principal; alarme U1 permanece separado)

---

### Question 8 — Custo

A) SNS + Athena queries de exemplo com volume mínimo; schedule default off; email subscription opcional

B) Mesmo que A + documentar custo estimado marginal SNS/Athena (~centavos) no lab-guide

X) Other (please describe after [Answer]: tag below)

[Answer]:B (custo mínimo + documentar estimativa marginal no lab-guide)

---

### Question 9 — Manutenibilidade / usabilidade operador

A) lab-guide: lista de Airflow Variables + `terraform output` mapping + passos sync/trigger/verify SNS

B) Mesmo que A + script helper `scripts/set-airflow-variables.ps1` (ou `.sh`) que lê outputs TF e seta Variables via API/CLI Airflow

X) Other (please describe after [Answer]: tag below)

[Answer]:B (lab-guide + script set-airflow-variables que lê outputs e seta Variables)

---

## 3. Defaults sugeridos (lab)

| Q | Sugestão |
|---|---|
| 1 | A |
| 2 | A |
| 3 | B |
| 4 | B (topic policy + least privilege) |
| 5 | B (provider + mecanismo install documentado) |
| 6 | A |
| 7 | A (SNS pipeline only; keep U1 alarm as-is) |
| 8 | B |
| 9 | A (docs; script helper opcional depois) |
