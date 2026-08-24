# U3 Compute Executors — NFR Requirements Plan

**Unidade**: U3  
**Entrada**: functional-design U3 + NFR U1/U2 (herdar padrões)  
**Saída**: `nfr-requirements.md` + `tech-stack-decisions.md`

Preencha cada `[Answer]:` e avise (`pronto`).

---

## 1. Checklist (após aprovação)

- [x] `nfr-requirements.md`
- [x] `tech-stack-decisions.md`
- [x] Apresentar para aprovação

---

## 2. Perguntas

### Question 1 — Escalabilidade dos executors

A) Tamanhos mínimos PoC: Lambda 128–256 MB; Glue **G.1X / 2 workers**; ECS Fargate **0.25 vCPU / 0.5 GB** — documentar headroom (mais memória/workers) sem provisionar agora (recomendado)

B) Já dimensionar “médio” (Lambda 1024 MB; Glue G.1X 5 workers; Fargate 1 vCPU / 2 GB)

C) Other (please describe after [Answer]: tag below)

[Answer]: A (tamanhos mínimos PoC + headroom documentado)

### Question 2 — Desempenho

A) Sem SLO formal; aceitar cold start Lambda, startup Glue/ECS típicos de lab

B) Definir metas informais (ex. Lambda p95 &lt; 3s; Glue &lt; 10 min no sample)

C) Other (please describe after [Answer]: tag below)

[Answer]: A (sem SLO formal)

### Question 3 — Disponibilidade

A) Best-effort PoC; sem multi-AZ explícito além do que Fargate/Glue/Lambda já oferecem; sem RTO/RPO

B) Exigir Fargate em 2 AZs com capacity provider + retry policies nos serviços

C) Other (please describe after [Answer]: tag below)

[Answer]: A (best-effort; sem multi-AZ explícito além do nativo)

### Question 4 — Segurança

A) Roles dedicadas least privilege; logs sem PII; sem secrets no git; Lambda/Glue/ECS só nos paths lake necessários; VPC para ECS (já FD) (recomendado)

B) Mesmo que A + Lambda **dentro da VPC** (subnets privadas) — mais ENI/custo frio

C) Other (please describe after [Answer]: tag below)

[Answer]: A (roles dedicadas least privilege; Lambda fora da VPC)

### Question 5 — Stack tecnológica (runtimes)

A) Lambda **Python 3.12**; Glue job **Glue 4.0 / Spark** (ou 5.0 se disponível na região); ECS imagem pública **amazon/aws-cli** ou amazonlinux com CLI (recomendado)

B) Lambda Node 20; Glue Python Shell; ECS imagem custom via ECR

C) Other (please describe after [Answer]: tag below)

[Answer]: A (Lambda Python 3.12; Glue 4.0/Spark; ECS imagem com CLI)

### Question 6 — Confiabilidade / observabilidade

A) Logs nativos: CloudWatch Logs (Lambda/ECS) + Glue job logs; **sem** alarmes SNS (SNS = U4)

B) Alarmes mínimos (Lambda Errors, Glue Failed, ECS Stopped) → SNS já em U3

C) Other (please describe after [Answer]: tag below)

[Answer]: A (logs nativos; sem alarmes SNS — fica em U4)

### Question 7 — Manutenibilidade

A) Código Lambda/Glue em `src/` (ou `compute/`) versionado; README U3 com invoke manual (CLI) + nota PassRole; `terraform fmt/validate`

B) Além de A: script `scripts/smoke-compute.sh` (invoke Lambda + start Glue + run ECS)

C) Other (please describe after [Answer]: tag below)

[Answer]: B (código versionado + README + script smoke-compute.sh)

### Question 8 — Usabilidade do operador

A) Outputs claros (ARNs/names) + exemplos AWS CLI no README para teste manual antes da U4

B) Só outputs Terraform; sem exemplos CLI

C) Other (please describe after [Answer]: tag below)

[Answer]: A (outputs claros + exemplos AWS CLI no README)

---

## 3. Decisões capturadas

| # | Decisão |
|---|---|
| 1 | Sizing mínimo PoC + headroom doc |
| 2 | Sem SLO formal |
| 3 | Best-effort availability |
| 4 | Least privilege; Lambda fora da VPC |
| 5 | Py 3.12 / Glue 4.0 Spark / ECS aws-cli público |
| 6 | Logs nativos; sem SNS |
| 7 | `src/` + README + `smoke-compute.sh` |
| 8 | Outputs + exemplos CLI |

## 4. Aprovação do plano

**Status**: respostas aceitas — artefatos gerados; aguardando aprovação dos Requisitos NFR U3
