# U2 Data Lake and Governance — Infrastructure Design Plan

**Unidade**: U2  
**Cloud**: AWS `us-east-1` / `dev` (herda U1)  
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

A) Mesma conta/região/profile da U1; novos modules no mesmo root Terraform (recomendado)

B) Stack Terraform separado (workspace/state) só para U2

C) Other (please describe after [Answer]: tag below)

[Answer]: A (mesma conta/região/root Terraform; novos modules)

### Question 2 — Compute (U2)

A) Compute = **Glue Crawlers** (managed) apenas; sem EC2/ECS/Lambda/Glue Job nesta unidade (Jobs = U3)

B) Incluir Glue Job stub vazio já em U2 (antecipa U3)

C) Other (please describe after [Answer]: tag below)

[Answer]: A (compute = só Glue Crawlers; Jobs ficam em U3)

### Question 3 — Storage

A) 2 buckets S3: `{prefix}-data` (versioning+BPA+SSE-S3+deny HTTP) e `{prefix}-athena-results` (+ lifecycle 7d); prefixes `raw/` e `processed/` lógicos (Hive `dt=` via seed/docs)

B) Um único bucket com prefixes data/ + athena-results/ (contra FD de 2 buckets)

C) Other (please describe after [Answer]: tag below)

[Answer]: A (2 buckets: -data e -athena-results com lifecycle 7d; prefixos raw/processed, Hive dt=)

### Question 4 — Mensageria

A) Nenhuma em U2 (SNS = U4) — N/A justificado

B) SNS topic placeholder para crawler failures

C) Other (please describe after [Answer]: tag below)

[Answer]: A (nenhuma mensageria; SNS = U4)

### Question 5 — Rede

A) Sem VPC nova; S3/Glue/LF/Athena regionais; tráfego S3 do MWAA já via Gateway Endpoint U1 (recomendado)

B) Adicionar Interface Endpoints Glue/Athena (custo ENI extra)

C) Other (please describe after [Answer]: tag below)

[Answer]: A (sem VPC nova; sem interface endpoints)

### Question 6 — Monitoramento

A) Logs/métricas nativas Glue Crawler + CloudTrail conta (se já existir); sem dashboards/alarmes U2

B) Dashboard CW simples (crawler runs) sem alarmes

C) Other (please describe after [Answer]: tag below)

[Answer]: A (logs/métricas nativas do crawler; sem dashboards/alarmes)

### Question 7 — Infra compartilhada

A) Atualizar `shared-infrastructure.md` com buckets lake, Glue DB, LF tags, Athena WG, grants MWAA (consumidos por U3/U4)

B) Não atualizar shared; só docs U2

C) Other (please describe after [Answer]: tag below)

[Answer]: A (atualizar shared-infrastructure.md)

### Question 8 — Glue / LF naming & roles

A) 1 Glue Database `{prefix}_lake`; crawlers `{prefix}-raw-crawler` / `{prefix}-processed-crawler`; IAM role dedicada Glue service; LF admin = prereq manual (recomendado)

B) Databases separados raw/processed (mais grants)

C) Other (please describe after [Answer]: tag below)

[Answer]: A (1 database {prefix}_lake; dois crawlers nomeados; role Glue dedicada; LF admin manual)

---

## 3. Decisões capturadas

| # | Decisão |
|---|---|
| 1 | Mesmo root TF / conta / região da U1 |
| 2 | Compute = só Glue Crawlers |
| 3 | 2 buckets data + athena-results (lifecycle 7d) |
| 4 | Sem mensageria (SNS = U4) |
| 5 | Sem VPC/endpoints novos |
| 6 | Logs nativos; sem dashboards/alarmes |
| 7 | Atualizar `shared-infrastructure.md` |
| 8 | 1 Glue DB + 2 crawlers + role Glue; LF admin manual |

## 4. Aprovação do plano

**Status**: respostas aceitas — artefatos gerados; aguardando aprovação do Infrastructure Design U2
