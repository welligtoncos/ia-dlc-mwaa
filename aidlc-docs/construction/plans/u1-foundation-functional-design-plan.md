# U1 Foundation — Functional Design Plan

**Unidade**: U1 Foundation (Platform)  
**Stories**: US-01, US-02, US-03, US-04, parte US-10  
**Foco**: lógica de negócio / regras de provisionamento (agnóstico a detalhes TF até Infrastructure Design)

Preencha cada `[Answer]:` e avise no chat (`pronto`).

---

## 1. Checklist de artefatos (Parte 2 — após aprovação)

- [x] `business-logic-model.md`
- [x] `business-rules.md`
- [x] `domain-entities.md`
- [x] Validar cobertura US-01..US-04 (+ US-10 base)
- [x] Apresentar para aprovação

---

## 2. Escopo da unidade (contexto)

U1 provisiona a **fundação** da plataforma: rede mínima MWAA, bucket de artefatos, ambiente MWAA, IAM base + policy do apply.  
Não inclui lake/LF/Athena (U2), executors (U3) nem DAG/SNS (U4).

---

## 3. Perguntas

### Question 1 — Modelo de “negócio” desta unidade IaC

A) Tratar como **capability de plataforma**: entidades = Environment, Network, ArtifactBucket, ExecutionIdentity, ApplyPrincipal (recomendado)

B) Tratar só como checklist de recursos AWS sem modelo de domínio explícito

C) Other (please describe after [Answer]: tag below)

[Answer]: A (capability de plataforma com entidades explícitas)

### Question 2 — Fluxo de provisionamento (ordem lógica)

A) Network → ArtifactBucket → ExecutionIdentity → MWAA Environment → validação de readiness (recomendado)

B) ArtifactBucket + Identity em paralelo com Network, depois MWAA

C) Other (please describe after [Answer]: tag below)

[Answer]: A (Network → ArtifactBucket → ExecutionIdentity → MWAA → readiness)

### Question 3 — Regras de aceite do MWAA (US-02)

A) Ambiente `AVAILABLE`, classe `mw1.small`, Airflow default `2.11.2` (override via var), web `PUBLIC`, logs CW ligados

B) Mesmo que A, mas exigir smoke HTTP 200 na UI no critério funcional (além de status AVAILABLE)

C) Other (please describe after [Answer]: tag below)

[Answer]: A (AVAILABLE + classe + versão default + PUBLIC + logs; sem exigir smoke HTTP)

### Question 4 — ArtifactStore (US-03)

A) Bucket dedicado só a artefatos Airflow (dags/plugins/requirements); versioning + BPA; sem upload no apply

B) Mesmo bucket do data lake com prefixo `airflow/` (não recomendado — mistura U1/U2)

C) Other (please describe after [Answer]: tag below)

[Answer]: A (bucket dedicado a artefatos Airflow)

### Question 5 — Política de apply (US-04)

A) Documento JSON comentado em `policies/` cobrindo só serviços U1 agora; U2–U4 ampliam depois

B) Documento já cobre **toda** a plataforma (U1–U4) desde o início (recomendado para um apply único)

C) Other (please describe after [Answer]: tag below)

[Answer]: B (política do apply cobre U1–U4 desde o início)

### Question 6 — Tratamento de erro / falha de provisionamento

A) Falha em qualquer passo → apply aborta; sem compensação automática (PoC; destroy manual)

B) Documentar runbook de rollback (`terraform destroy` parcial / full) como regra operacional mínima

C) A + B (recomendado)

D) Other (please describe after [Answer]: tag below)

[Answer]: C (A + B)

### Question 7 — Naming / identidade de domínio

A) Prefixo `{project}-{env}-` em nomes (ex.: `ia-dlc-mwaa-dev-...`)

B) Prefixo curto `{project}-` sem env no nome (env só em tags)

C) Other (please describe after [Answer]: tag below)

[Answer]: A (prefixo {project}-{env}-)

---

## 4. Decisões capturadas

| # | Decisão |
|---|---|
| 1 | Capability de plataforma com entidades explícitas |
| 2 | Ordem: Network → ArtifactBucket → ExecutionIdentity → MWAA → readiness |
| 3 | Aceite MWAA: AVAILABLE + mw1.small + 2.11.2 default + PUBLIC + logs (sem smoke HTTP) |
| 4 | Bucket dedicado a artefatos Airflow; sem upload no apply |
| 5 | Policy de apply cobre U1–U4 desde o início |
| 6 | Apply aborta em falha + runbook de rollback documentado |
| 7 | Naming `{project}-{env}-` |

## 5. Aprovação do plano

**Status**: plano aprovado — artefatos gerados; aguardando aprovação do Design Funcional U1
