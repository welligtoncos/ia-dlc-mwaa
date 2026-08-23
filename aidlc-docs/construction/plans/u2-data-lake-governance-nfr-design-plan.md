# U2 Data Lake and Governance — NFR Design Plan

**Unidade**: U2  
**Entrada**: `nfr-requirements.md`, `tech-stack-decisions.md`, functional-design U2  
**Saída**: `nfr-design-patterns.md`, `logical-components.md`

Preencha cada `[Answer]:` e avise (`pronto`).

---

## 1. Checklist (após aprovação)

- [x] `nfr-design-patterns.md`
- [x] `logical-components.md`
- [x] Apresentar para aprovação

---

## 2. Perguntas

### Question 1 — Padrões de resiliência

A) Fail-fast no apply TF; falha LF/crawler tratada como erro operacional documentado (sem retry de crawler no TF); seed script com retry simples de upload S3 (recomendado)

B) Mesmo que A + wrapper que re-tenta `StartCrawler` / grant LF via CLI pós-apply

C) Other (please describe after [Answer]: tag below)

[Answer]: A (fail-fast no apply; erro de LF/crawler documentado; seed script com retry de upload)

### Question 2 — Padrões de escalabilidade

A) Scale-by-config: vars para nomes de DB/crawlers/paths; headroom de schedule documentado no design (não criar `schedule` no recurso agora)

B) Crawlers já com `schedule` desabilitável via var (mais superfície agora)

C) Other (please describe after [Answer]: tag below)

[Answer]: A (scale-by-config; headroom de schedule documentado, sem criar schedule agora)

### Question 3 — Padrões de desempenho

A) Sem cache/fila; lifecycle 7d no results bucket; crawlers on-demand; Athena workgroup enforce config (recomendado)

B) Particionamento/Hive-style paths pré-desenhados no design além de raw/processed (complexidade extra)

C) Other (please describe after [Answer]: tag below)

[Answer]: B (particionamento Hive-style pré-desenhado no design)

### Question 4 — Padrões de segurança

A) Defense-in-depth: BPA + SSE-S3 ambos buckets + LF-Tags + least-privilege grants (crawler role, Athena, MWAA exec) + sem dados sensíveis no sample

B) Mesmo que A + bucket policies deny insecure transport (`aws:SecureTransport`) nos dois buckets

C) Other (please describe after [Answer]: tag below)

[Answer]: B (defense-in-depth + bucket policies deny insecure transport)

### Question 5 — Componentes lógicos NFR a modelar

A) SecurityBaseline (BPA/SSE/LF), CatalogBoundary (Glue DB/crawlers), GovernanceBoundary (LF tags/grants), QueryBoundary (Athena WG), CostGuardrail (lifecycle 7d), OperatorTooling (README + seed-sample.sh)

B) Só SecurityBaseline + GovernanceBoundary + QueryBoundary (mínimo)

C) Other (please describe after [Answer]: tag below)

[Answer]: A (os seis componentes lógicos)

---

## 3. Decisões capturadas

| # | Decisão |
|---|---|
| 1 | Fail-fast TF; erros LF/crawler documentados; retry só no seed script |
| 2 | Scale-by-config; schedule = headroom documentado |
| 3 | Hive-style `dt=YYYY-MM-DD/` sob raw/processed |
| 4 | Defense-in-depth + deny `aws:SecureTransport=false` |
| 5 | 6 componentes lógicos NFR |

## 4. Aprovação do plano

**Status**: respostas aceitas — artefatos gerados; aguardando aprovação do Design NFR U2
