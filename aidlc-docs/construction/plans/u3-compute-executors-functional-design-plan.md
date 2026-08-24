# U3 Compute Executors — Functional Design Plan

**Unidade**: U3 Compute Executors  
**Stories**: US-06, US-07, parte US-10  
**Depende de**: U1 (MWAA role, VPC/subnets para ECS); U2 (paths lake / catalog via outputs)  
**Foco**: lógica dos executors (agnóstico a detalhe TF até Infrastructure Design)

Preencha cada `[Answer]:` e avise (`pronto`).

---

## 1. Checklist de artefatos (após aprovação deste plano)

- [x] `business-logic-model.md`
- [x] `business-rules.md`
- [x] `domain-entities.md`
- [x] Validar cobertura US-06, US-07, US-10 (compute)
- [x] Apresentar para aprovação

---

## 2. Escopo da unidade

U3 provisiona:
- Lambda de exemplo + role (invocável pelo MWAA)
- Glue Job de exemplo + role (S3 lake + Catalog)
- ECS cluster + task definition Fargate de exemplo + roles
- Grants na execution role MWAA para Start/Invoke/RunTask (least privilege)

**Não inclui**: rede/MWAA (U1), lake/LF/Athena base (U2), DAG/SNS (U4).

---

## 3. Perguntas

### Question 1 — Comportamento da Lambda (US-06)

A) Lambda **hello/log**: recebe evento do Airflow, loga payload, retorna status OK (mínimo didático)

B) Lambda **escreve marcador** em `s3://data/raw/dt=.../lambda_marker.json` (integra com lake U2)

C) Other (please describe after [Answer]: tag below)

[Answer]: B (Lambda escreve marcador no lake — integra com U2)

### Question 2 — Comportamento do Glue Job (US-07)

A) Job **passthrough**: lê sample em `raw/`, grava cópia/Parquet simples em `processed/dt=.../` (recomendado PoC)

B) Job **só stub**: script mínimo que loga e termina sem I/O de lake (mais frágil para demo E2E)

C) Other (please describe after [Answer]: tag below)

[Answer]: A (Glue job passthrough: raw → Parquet particionado em processed/dt=.../)

### Question 3 — Comportamento da task ECS Fargate (US-07)

A) Task **echo/sleep**: container público leve (ex. `amazonlinux`/`busybox`) que imprime env e sai 0

B) Task **escreve marcador** no lake (`processed/` ou `raw/`) via AWS CLI na imagem

C) Other (please describe after [Answer]: tag below)

[Answer]: B (ECS escreve marcador no lake via CLI)

### Question 4 — Empacotamento dos artefatos de código

A) Lambda: zip local via Terraform (`archive_file`); Glue script: objeto S3 no **artifact bucket U1**; ECS: imagem **pública** (sem ECR) — recomendado PoC

B) Tudo via S3/ECR próprios (Lambda layer/S3, Glue S3, ECR com build local)

C) Other (please describe after [Answer]: tag below)

[Answer]: A (Lambda zip local; Glue script no artifact bucket U1; ECS imagem pública)

### Question 5 — Modelo de identidades (US-10 compute)

A) **Uma role por executor** (Lambda / Glue / ECS task+execution) + policies mínimas; MWAA só `lambda:InvokeFunction`, `glue:StartJobRun`(+Get*), `ecs:RunTask`(+Describe/Stop) e `iam:PassRole` nos roles ECS/Glue — recomendado

B) Role compartilhada “compute” para os três (mais simples, pior isolation)

C) Other (please describe after [Answer]: tag below)

[Answer]: A (uma role por executor + grants mínimos no MWAA)

### Question 6 — Rede ECS

A) Task Fargate nas **subnets privadas U1** + SG dedicado egress (NAT já existente); assign public IP = false

B) Task em subnet pública com IP público (evita NAT para pulls; menos alinhado ao lab MWAA)

C) Other (please describe after [Answer]: tag below)

[Answer]: A (Fargate em subnets privadas U1 + SG egress; sem IP público)

### Question 7 — Fluxo de dados / ordem lógica (para U4 depois)

A) Contrato lógico: Lambda (opcional marker) → Glue (raw→processed) → ECS (echo/marker) — **sem orquestrar aqui** (só contratos/outputs)

B) U3 já cria um “runner” auxiliar (Step Functions/EventBridge) fora do MWAA

C) Other (please describe after [Answer]: tag below)

[Answer]: A (só contratos/outputs; sem orquestrar aqui)

### Question 8 — Erros e idempotência

A) Fail-fast: falha de invoke/job/task propaga ao caller (Airflow em U4); sem retry no TF; scripts/jobs idempotentes o suficiente para re-run PoC

B) Retries embutidos nos jobs (Glue job bookmark / Lambda retry config agressivo) já em U3

C) Other (please describe after [Answer]: tag below)

[Answer]: A (fail-fast; jobs idempotentes; sem retry no TF)

### Question 9 — Módulos Terraform (preview; confirmação)

A) Modules: `lambda_executor`, `glue_job`, `ecs_executor` + wiring root + policy aditiva MWAA (recomendado)

B) Um único module `compute` monolítico

C) Other (please describe after [Answer]: tag below)

[Answer]: A (módulos lambda_executor, glue_job, ecs_executor + policy aditiva MWAA)

---

## 4. Decisões capturadas

| # | Decisão |
|---|---|
| 1 | Lambda escreve marcador em `raw/dt=` |
| 2 | Glue passthrough raw → Parquet `processed/dt=` |
| 3 | ECS escreve marcador no lake via CLI |
| 4 | Zip TF + script no artifact U1 + imagem pública |
| 5 | Uma role por executor + grants MWAA mínimos |
| 6 | Fargate em subnets privadas U1, sem IP público |
| 7 | Só contratos; orquestração = U4 |
| 8 | Fail-fast; sem retry no TF |
| 9 | Modules `lambda_executor`, `glue_job`, `ecs_executor` |

## 5. Aprovação do plano

**Status**: respostas aceitas — artefatos gerados; aguardando aprovação do Design Funcional U3
