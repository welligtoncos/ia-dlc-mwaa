# U1-orchestrator-ec2 — Functional Design Plan

**Unidade lógica**: U1 Foundation delta (OrchestratorEC2)  
**FRs**: FR-EC2-01..08  
**Foco**: lógica de negócio / regras de provisionamento e operação do orquestrador EC2 (agnóstico a detalhes TF até Infrastructure Design)

Preencha cada `[Answer]:` e avise no chat (`pronto`).

---

## 1. Checklist de artefatos (Parte 2 — após aprovação do plano)

- [x] `business-logic-model.md`
- [x] `business-rules.md`
- [x] `domain-entities.md`
- [x] Validar cobertura FR-EC2-01..08
- [x] Apresentar para aprovação (2 opções)

---

## 2. Escopo

**Inclui**: EC2 Airflow Compose, SG UI, role EC2 + SSM, upload compose package no ArtifactStore, DagSyncAgent, `orchestrator_mode`, scripts start/stop, critério de aceite sem MWAA.  
**Não inclui**: lake/LF (U2), código dos executors (U3), DAG E2E/SNS (U4), detalhe de AMI IDs/Terraform resource names (Infrastructure Design).

---

## 3. Perguntas

### Question 1 — Modelo de domínio deste delta

A) Entidades: `OrchestratorMode`, `AirflowHost` (EC2), `ComposeStack`, `DagSyncAgent`, `OperatorAccess` (CIDR + SSM), `ExecutionIdentity` (EC2 role)

B) Só checklist de recursos AWS sem entidades explícitas

X) Other (please describe after [Answer]: tag below)

[Answer]: A (entidades de domínio explícitas)

---

### Question 2 — Ordem lógica de provisionamento (mode=ec2)

A) Network (já existe) → ArtifactStore (compose package upload) → ExecutionIdentity EC2 → AirflowHost EC2 + bootstrap → DagSyncAgent timer → readiness (UI/SSM)

B) Identity + EC2 em paralelo com upload compose; bootstrap no boot só

X) Other (please describe after [Answer]: tag below)

[Answer]: A (ordem: ArtifactStore → Identity → EC2+bootstrap → DagSyncAgent → readiness)

---

### Question 3 — Critério de aceite funcional (US-02 substituído)

A) EC2 `running`; containers Compose healthy (webserver+scheduler+postgres); UI HTTP alcançável do `operator_cidr` na :8080; SSM `start-session` ok; **sem** exigir DAG E2E (U4)

B) Mesmo que A + smoke mínimo: listar DAGs via UI/API após sync de um DAG placeholder

X) Other (please describe after [Answer]: tag below)

[Answer]: B (aceite + smoke mínimo: listar DAGs após sync de um placeholder)

---

### Question 4 — Credenciais UI Airflow (lab)

A) Defaults documentados no README (`admin` / senha fixa de lab em var sensível ou plaintext PoC) — trocar se expor além do CIDR

B) Senha gerada no bootstrap e gravada só em SSM Parameter / Secrets Manager

X) Other (please describe after [Answer]: tag below)

[Answer]: B (senha gerada no bootstrap, gravada em SSM Parameter Store)

---

### Question 5 — Intervalo do DagSyncAgent

A) A cada **5 minutos** (cron/systemd)

B) A cada **1 minuto**

C) Só sync manual via script na EC2 (sem timer) — operador dispara após `sync-dags.sh`

X) Other (please describe after [Answer]: tag below)

[Answer]: A (sync a cada 5 minutos)

---

### Question 6 — Falha de bootstrap (Docker/Compose/S3 pull)

A) Fail-fast: instancia sobe mas serviço systemd marca failed; operador inspeciona via SSM/logs; **não** auto-recreate da EC2 no TF

B) user_data com retries limitados (ex.: 3) no pull S3 + `compose up`; depois failed

X) Other (please describe after [Answer]: tag below)

[Answer]: B (user_data com retries limitados no pull S3 + compose up, depois failed)

---

### Question 7 — Comportamento stop/start vs metadados Airflow

A) Aceitar: Postgres no volume Docker local — **dados de metadata sobrevivem** a stop/start da EC2 se o volume EBS root persistir; destroy da instancia perde metadata (recriar lab)

B) Metadata descartável: sempre reset no boot (`compose down -v` implícito) — lab limpo a cada start

X) Other (please describe after [Answer]: tag below)

[Answer]: A (Postgres em volume Docker; metadata sobrevive a stop/start, perde no destroy)

---

## 4. Após respostas

1. Análise de ambiguidades  
2. **Aprovar plano de design funcional** / Solicitar alterações  
3. Gerar artefatos na pasta `aidlc-docs/construction/u1-orchestrator-ec2/functional-design/`  
4. Gate: Solicitar Alterações | Continuar para NFR Requirements
