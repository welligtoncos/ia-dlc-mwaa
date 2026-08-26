# U1-orchestrator-ec2 — NFR Requirements Plan

**Unidade**: U1-orchestrator-ec2 (delta Foundation)  
**Próximo artefato**: `nfr-requirements.md` + `tech-stack-decisions.md`  
**Contexto**: PoC `dev` / `us-east-1`; EC2 t3.medium + Compose; SSM-only; SG CIDR; ~US$ 1–2/dia; Free Tier bloqueia MWAA

Preencha cada `[Answer]:` e avise (`pronto`).

---

## 1. Checklist (após aprovação deste plano)

- [x] `aidlc-docs/construction/u1-orchestrator-ec2/nfr-requirements/nfr-requirements.md`
- [x] `aidlc-docs/construction/u1-orchestrator-ec2/nfr-requirements/tech-stack-decisions.md`
- [x] Apresentar para aprovação (2 opções)

---

## 2. Perguntas

### Question 1 — Escalabilidade

A) Sem meta de escala: **1× t3.medium** + LocalExecutor basta para lab (recomendado PoC)

B) Documentar headroom: upgrade path para t3.large ou CeleryExecutor + workers **sem implementar** agora

X) Other (please describe after [Answer]: tag below)

[Answer]: B (documentar headroom para t3.large/CeleryExecutor sem implementar)

---

### Question 2 — Desempenho

A) Sem SLO formal; aceitar boot EC2 + pull S3 + `compose up` (minutos) e sync DAGs a cada 5 min

B) SLO soft: UI Airflow respondendo em < 30s após stack healthy

X) Other (please describe after [Answer]: tag below)

[Answer]: A (sem SLO formal)

---

### Question 3 — Disponibilidade

A) Best-effort PoC: **single EC2 = SPOF**; sem HA; stop/start manual para custo

B) Documentar RTO soft (ex.: recriar EC2 + re-sync DAGs < 1h) sem multi-AZ

X) Other (please describe after [Answer]: tag below)

[Answer]: B (documentar RTO soft: recriar EC2 + re-sync < 1h)

---

### Question 4 — Segurança (orquestrador EC2)

A) Least privilege + BPA + SG 8080 só `operator_cidr` + SSM-only + senha UI em SSM Parameter (SecureString)

B) Mesmo que A + IMDSv2 **required** na EC2 + encryption SSE-S3 no bucket (já U1)

C) Mesmo que B + bloquear egress da EC2 a faixas mínimas (HTTPS/DNS/S3/Glue endpoints) — mais restritivo

X) Other (please describe after [Answer]: tag below)

[Answer]: B (least privilege + SG/SSM/senha em SSM + IMDSv2 required + SSE-S3)

---

### Question 5 — Stack tecnológica (fixar)

A) Terraform >= 1.5 + AWS ~> 5.0; Docker Compose v2 no AL2023; imagem `apache/airflow:2.11.2`; Postgres 13+ no Compose; AWS CLI v2 na EC2

B) Incluir também `docker compose` via pacote oficial + pin de digest da imagem Airflow

X) Other (please describe after [Answer]: tag below)

[Answer]: B (stack fixa + docker compose via pacote oficial + pin de digest da imagem)

---

### Question 6 — Observabilidade

A) CloudWatch Logs via **agent/ssm** ou logs Docker → journald; sem alarmes SNS nesta unidade

B) Alarme CloudWatch mínimo: EC2 status check failed → (sem SNS até U4)

C) Alarme + métrica custom (ex.: systemd unit failed) documentada; SNS em U4

X) Other (please describe after [Answer]: tag below)

[Answer]: B (alarme CloudWatch de status check failed; sem SNS até U4)

---

### Question 7 — Custo / operação

A) README + scripts start/stop; aviso ~US$ 1–2/dia; recomendar stop quando idle; destroy perde metadata Airflow

B) Mesmo que A + tag `CostCenter=lab` / budget alert sugerido (fora do TF)

X) Other (please describe after [Answer]: tag below)

[Answer]: B (scripts start/stop + tag CostCenter=lab + budget alert sugerido)

---

### Question 8 — Manutenibilidade

A) `terraform fmt` + `validate`; README seção EC2 Airflow; checklist IAM antes apply; documentar IP dinâmico pós stop/start

B) Mesmo que A + script `scripts/airflow-ec2-status.sh` (SSM + curl UI)

X) Other (please describe after [Answer]: tag below)

[Answer]: B (fmt/validate + README + airflow-ec2-status.sh)

---

## 3. Após respostas

1. Análise de ambiguidades  
2. **Aprovar plano NFR** / Solicitar alterações  
3. Gerar artefatos em `aidlc-docs/construction/u1-orchestrator-ec2/nfr-requirements/`  
4. Gate: Solicitar Alterações | Continuar para NFR Design
