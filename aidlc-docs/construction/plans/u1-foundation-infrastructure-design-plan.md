# U1 Foundation — Infrastructure Design Plan

**Unidade**: U1 Foundation  
**Cloud**: AWS `us-east-1` / `dev`  
**Saída**: `infrastructure-design.md`, `deployment-architecture.md` (+ shared se aplicável)

Preencha cada `[Answer]:` e avise (`pronto`).

---

## 1. Checklist (após aprovação)

- [x] `infrastructure-design.md` — mapa lógico → recursos AWS
- [x] `deployment-architecture.md` — topologia / apply
- [x] Avaliar necessidade de `shared-infrastructure.md`
- [x] Apresentar para aprovação

---

## 2. Perguntas

### Question 1 — Ambiente de implantação

A) Conta AWS única `dev`, região fixa `us-east-1`, profile CLI default/dev (recomendado)

B) Conta única, região via variável (default us-east-1) para facilitar clone depois

C) Other (please describe after [Answer]: tag below)

[Answer]: B (conta única, região via variável com default us-east-1)

### Question 2 — Compute (U1)

A) Compute = somente **MWAA mw1.small** (sem EC2/ECS/Lambda nesta unidade)

B) Incluir bastion EC2 opcional para debug privado (fora do escopo mínimo)

C) Other (please describe after [Answer]: tag below)

[Answer]: A (compute = só MWAA mw1.small)

### Question 3 — Storage (U1)

A) Um S3 ArtifactBucket (SSE-S3, versioning, BPA) + CloudWatch Log Groups via MWAA

B) ArtifactBucket + bucket separado só para logs (não necessário com MWAA logs nativos)

C) Other (please describe after [Answer]: tag below)

[Answer]: A (um ArtifactBucket + Log Groups nativos do MWAA)

### Question 4 — Mensageria (U1)

A) Nenhuma (SNS fica em U4) — N/A justificado

B) Criar SNS topic “placeholder” já em U1 para alarmes futuros

C) Other (please describe after [Answer]: tag below)

[Answer]: A (nenhuma mensageria; SNS fica em U4)

### Question 5 — Rede

A) VPC /24+ com 2 private + 1 public, 1 NAT, IGW, SG MWAA, **S3 Gateway Endpoint** nas RTs privadas (recomendado)

B) Mesmo que A + Interface Endpoints (STS/Logs/Airflow) — mais custo/ENI

C) Other (please describe after [Answer]: tag below)

[Answer]: A (rede + S3 Gateway Endpoint, sem interface endpoints)

### Question 6 — Monitoramento

A) Apenas logs CW do MWAA + status AVAILABLE (sem dashboards/alarmes)

B) Dashboard CloudWatch simples (métricas MWAA) sem alarmes

C) Other (please describe after [Answer]: tag below)

[Answer]: A (logs CW + status AVAILABLE; sem dashboards/alarmes)

### Question 7 — Infra compartilhada entre unidades

A) Criar `shared-infrastructure.md`: VPC/MWAA/ArtifactBucket/IAM base são shared foundation para U2–U4

B) Não criar shared doc; cada unidade documenta só seus recursos

C) Other (please describe after [Answer]: tag below)

[Answer]: A (criar shared-infrastructure.md)

### Question 8 — CIDRs default

A) VPC `10.0.0.0/16`; public `10.0.0.0/24`; private `10.0.1.0/24` + `10.0.2.0/24`

B) VPC `10.10.0.0/16`; public `10.10.0.0/24`; private `10.10.1.0/24` + `10.10.2.0/24`

C) Other (please describe after [Answer]: tag below)

[Answer]: B (VPC 10.10.0.0/16)

---

## 3. Decisões capturadas

| # | Decisão |
|---|---|
| 1 | Região via variável (default `us-east-1`) |
| 2 | Compute U1 = só MWAA `mw1.small` |
| 3 | 1 ArtifactBucket + CW logs nativos MWAA |
| 4 | Sem mensageria em U1 (SNS = U4) |
| 5 | VPC + 1 NAT + SG + **S3 Gateway Endpoint** (sem interface endpoints) |
| 6 | Monitoramento = logs + AVAILABLE |
| 7 | Criar `shared-infrastructure.md` |
| 8 | CIDRs: VPC `10.10.0.0/16`; pub `10.10.0.0/24`; priv `10.10.1.0/24` + `10.10.2.0/24` |

## 4. Aprovação do plano

**Status**: plano aprovado — artefatos gerados; aguardando aprovação do Infrastructure Design U1
