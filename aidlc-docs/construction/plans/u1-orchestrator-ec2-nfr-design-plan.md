# U1-orchestrator-ec2 — NFR Design Plan

**Unidade**: U1-orchestrator-ec2  
**Entrada**: `nfr-requirements.md`, `tech-stack-decisions.md`  
**Saída**: `nfr-design-patterns.md`, `logical-components.md`

Preencha cada `[Answer]:` e avise (`pronto`).

---

## 1. Checklist (após aprovação)

- [x] `aidlc-docs/construction/u1-orchestrator-ec2/nfr-design/nfr-design-patterns.md`
- [x] `aidlc-docs/construction/u1-orchestrator-ec2/nfr-design/logical-components.md`
- [x] Apresentar para aprovação (2 opções)

---

## 2. Perguntas

### Question 1 — Padrões de resiliência (bootstrap EC2)

A) Retries limitados no user_data (pull S3 + compose up); fail-fast após N tentativas; recovery manual via SSM/re-run bootstrap script

B) Systemd unit com `Restart=on-failure` no compose stack (auto-restart containers only)

C) A + B (retries no boot + restart de containers)

X) Other (please describe after [Answer]: tag below)

[Answer]: C (retries no boot + Restart=on-failure nos containers)

---

### Question 2 — Padrões de escalabilidade

A) Scale-by-config: variável `airflow_instance_type` default `t3.medium`; documentar `t3.large` e CeleryExecutor sem implementar

B) Módulo já com ASG min=1 max=1 (complexidade desnecessária para lab)

X) Other (please describe after [Answer]: tag below)

[Answer]: A (scale-by-config; t3.large/Celery documentados sem implementar)

---

### Question 3 — Padrões de desempenho

A) Sem cache/fila; DAG sync a cada 5 min aceito; grafo TF enxuto (EC2 + SG + alarm + SSM param)

B) Pré-pull imagem Docker no user_data com retry separado antes do compose up

X) Other (please describe after [Answer]: tag below)

[Answer]: B (pré-pull da imagem Docker com retry separado antes do compose up)

---

### Question 4 — Padrões de segurança

A) Defense-in-depth: IMDSv2 + SG CIDR + SSM-only + senha SSM SecureString + least-privilege role + SSE-S3 bucket

B) Mesmo que A + **VPC Gateway Endpoint S3** reutilizado (reduz egress NAT para sync/pull)

C) Mesmo que B + SSM VPC interface endpoint (custo extra; SSM sem internet)

X) Other (please describe after [Answer]: tag below)

[Answer]: B (defense-in-depth + reusar o S3 Gateway Endpoint; sem SSM interface endpoint)

---

### Question 5 — Logging / observabilidade lógica

A) Logs Docker → **journald** na EC2; operador consulta via SSM + `journalctl`; alarme CW status check only

B) **CloudWatch agent** na EC2 enviando logs compose para log group dedicado

C) A + alarme CW status check (sem SNS até U4)

X) Other (please describe after [Answer]: tag below)

[Answer]: C (logs Docker → journald + alarme CW status check)

---

### Question 6 — Componentes lógicos NFR a modelar

A) SecurityBaseline, BootstrapAgent, DagSyncAgent, CostGuardrail, OperatorTooling, HealthMonitor (CW alarm)

B) Só SecurityBaseline + BootstrapAgent (mínimo)

X) Other (please describe after [Answer]: tag below)

[Answer]: A (os seis componentes lógicos)

---

## 3. Após respostas

1. Análise de ambiguidades  
2. **Aprovar plano NFR Design** / Solicitar alterações  
3. Gerar artefatos em `aidlc-docs/construction/u1-orchestrator-ec2/nfr-design/`  
4. Gate: Solicitar Alterações | Continuar para Infrastructure Design
