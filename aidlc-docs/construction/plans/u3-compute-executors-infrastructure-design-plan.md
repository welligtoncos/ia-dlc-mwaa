# U3 Compute Executors — Infrastructure Design Plan

**Unidade**: U3  
**Cloud**: AWS `us-east-1` / `dev` (herda U1/U2)  
**Saída**: `infrastructure-design.md`, `deployment-architecture.md` (+ update shared se aplicável)

Preencha cada `[Answer]:` e avise (`pronto`).

---

## 1. Checklist (após aprovação)

- [x] `infrastructure-design.md`
- [x] `deployment-architecture.md`
- [x] Avaliar update de `shared-infrastructure.md`
- [x] Apresentar para aprovação

---

## 2. Perguntas

### Question 1 — Ambiente de implantação

A) Mesma conta/região/root Terraform da U1/U2; modules novos no mesmo state (recomendado)

B) Stack/state separado só para U3

C) Other (please describe after [Answer]: tag below)

[Answer]: A (mesma conta/região/root; modules novos no mesmo state)

### Question 2 — Compute

A) Lambda (zip) + Glue Job (G.1X×2) + ECS Fargate task (sem ECS Service permanente) — recomendado

B) Mesmo que A + ECS Service always-on (custo contínuo)

C) Other (please describe after [Answer]: tag below)

[Answer]: A (Lambda + Glue Job + Fargate task efêmera; sem ECS Service always-on)

### Question 3 — Storage

A) Sem buckets novos; usa data lake U2 + artifact bucket U1 (script Glue + opcional artefatos Lambda auxiliar) (recomendado)

B) Bucket dedicado `compute-artifacts` para scripts/zips

C) Other (please describe after [Answer]: tag below)

[Answer]: A (sem buckets novos; usa lake U2 + artifact bucket U1)

### Question 4 — Mensageria

A) Nenhuma em U3 (SNS/SQS = U4 / deferred) — N/A justificado

B) SQS DLQ para Lambda já em U3

C) Other (please describe after [Answer]: tag below)

[Answer]: A (nenhuma mensageria; SNS/SQS ficam em U4)

### Question 5 — Rede

A) ECS: subnets privadas U1 + SG egress; Lambda **sem** VPC; sem ALB/API GW; sem Interface Endpoints novos (recomendado)

B) Lambda em VPC + Interface Endpoints (Logs/STS/ECR)

C) Other (please describe after [Answer]: tag below)

[Answer]: A (ECS em subnet privada; Lambda sem VPC; sem interface endpoints)

### Question 6 — Monitoramento

A) Log groups nativos Lambda/ECS + Glue job logs; retenção 14–30 dias; sem dashboards/alarmes U3

B) Dashboard CW simples + alarmes → SNS (antecipa U4)

C) Other (please describe after [Answer]: tag below)

[Answer]: A (log groups nativos com retenção 14–30d; sem dashboards/alarmes)

### Question 7 — Infra compartilhada

A) Atualizar `shared-infrastructure.md` com Lambda/Glue/ECS ARNs e grants MWAA (consumidos por U4)

B) Não atualizar shared; só docs U3

C) Other (please describe after [Answer]: tag below)

[Answer]: A (atualizar shared-infrastructure.md)

### Question 8 — Naming / Glue script path

A) Nomes `{prefix}lambda-marker`, `{prefix}glue-passthrough`, `{prefix}ecs-cluster` / task family; script em `s3://{artifact}/scripts/glue_passthrough.py` (recomendado)

B) Nomes curtos sem prefix de projeto

C) Other (please describe after [Answer]: tag below)

[Answer]: A (nomes com prefixo; script Glue no artifact bucket U1)

---

## 3. Decisões capturadas

| # | Decisão |
|---|---|
| 1 | Mesmo root TF / conta / região |
| 2 | Lambda + Glue Job + Fargate task (sem Service) |
| 3 | Sem buckets novos (U1 artifact + U2 lake) |
| 4 | Sem mensageria (SNS/SQS = U4) |
| 5 | ECS privado; Lambda sem VPC; sem endpoints novos |
| 6 | Logs nativos 14–30d; sem alarmes |
| 7 | Atualizar shared-infrastructure |
| 8 | Naming com prefix; Glue script em artifact/scripts/ |

## 4. Aprovação do plano

**Status**: respostas aceitas — artefatos gerados; aguardando aprovação do Infrastructure Design U3
