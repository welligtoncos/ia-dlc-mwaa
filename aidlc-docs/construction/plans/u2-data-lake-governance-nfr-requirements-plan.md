# U2 Data Lake and Governance — NFR Requirements Plan

**Unidade**: U2  
**Entrada**: functional-design U2 + NFR U1 (herdar padrões)  
**Saída**: `nfr-requirements.md` + `tech-stack-decisions.md`

Preencha cada `[Answer]:` e avise (`pronto`).

---

## 1. Checklist (após aprovação)

- [x] `nfr-requirements.md`
- [x] `tech-stack-decisions.md`
- [x] Apresentar para aprovação

---

## 2. Perguntas

### Question 1 — Segurança dos buckets lake

A) BPA total + SSE-S3 em **ambos** os buckets (dados e Athena results) — alinhado à U1 (recomendado)

B) BPA + SSE-KMS com CMK dedicada (mais custo/complexidade)

C) Other (please describe after [Answer]: tag below)

[Answer]: A (BPA total + SSE-S3 em ambos os buckets)

### Question 2 — Lifecycle / custo de resultados Athena

A) Lifecycle no bucket Athena: expirar objetos após **7 dias** (recomendado PoC)

B) Sem lifecycle (manter resultados indefinidamente)

C) Other (please describe after [Answer]: tag below)

[Answer]: A (lifecycle expirando resultados Athena após 7 dias)

### Question 3 — Escalabilidade do catálogo

A) Sem meta formal; 2 crawlers on-demand bastam para lab

B) Documentar headroom (schedules diários / mais crawlers) sem implementar schedule agora

C) Other (please describe after [Answer]: tag below)

[Answer]: B (documentar headroom de schedule/mais crawlers sem implementar)

### Question 4 — Lake Formation / disponibilidade

A) Best-effort PoC; documentar dependência de LF admin pré-configurado

B) Incluir health-check script pós-apply (list databases / dry-run grant)

C) Other (please describe after [Answer]: tag below)

[Answer]: A (best-effort; documentar dependência de LF admin pré-configurado)

### Question 5 — Observabilidade U2

A) Logs Glue Crawler nativos + métricas default; sem alarmes SNS (SNS = U4)

B) Alarmes CloudWatch mínimos (crawler failed) → SNS (antecipa U4)

C) Other (please describe after [Answer]: tag below)

[Answer]: A (logs nativos do crawler; sem alarmes SNS — SNS fica em U4)

### Question 6 — Stack / módulos Terraform

A) Novos modules sob `terraform/modules/`: `data_lake`, `glue_catalog`, `lake_formation`, `athena` + wiring no root (recomendado)

B) Tudo em arquivos flat no root sem submodules U2

C) Other (please describe after [Answer]: tag below)

[Answer]: A (submodules data_lake, glue_catalog, lake_formation, athena)

### Question 7 — Manutenibilidade / docs

A) README: seção U2 com pré-req LF admin, upload sample, como rodar crawlers e query Athena

B) Além de A: script `scripts/seed-sample.sh` para upload do CSV de exemplo

C) Other (please describe after [Answer]: tag below)

[Answer]: B (README + script seed-sample.sh para o CSV de exemplo)

---

## 3. Aprovação

- `Aprovar plano NFR U2` — gera artefatos
- `Solicitar alterações` — descreva o ajuste
