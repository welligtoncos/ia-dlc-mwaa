# U1 Foundation — NFR Requirements Plan

**Unidade**: U1 Foundation  
**Próximo artefato**: `nfr-requirements.md` + `tech-stack-decisions.md`  
**Contexto**: PoC `dev` / `us-east-1`; MWAA small; 1 NAT; UI PUBLIC; least privilege

Preencha cada `[Answer]:` e avise (`pronto`).

---

## 1. Checklist (após aprovação deste plano)

- [x] `aidlc-docs/construction/u1-foundation/nfr-requirements/nfr-requirements.md`
- [x] `aidlc-docs/construction/u1-foundation/nfr-requirements/tech-stack-decisions.md`
- [x] Apresentar para aprovação

---

## 2. Perguntas

### Question 1 — Escalabilidade (U1)

A) Sem meta de escala: `mw1.small` + 1 NAT bastam para lab (recomendado PoC)

B) Planejar headroom: documentar caminho futuro para `mw1.medium` / 2 NAT sem implementar agora

C) Other (please describe after [Answer]: tag below)

[Answer]: B (documentar headroom para mw1.medium / 2 NAT sem implementar)

### Question 2 — Desempenho

A) Sem SLO formal; aceitar tempos típicos de create MWAA (20–40+ min) e cold start de apply

B) Definir SLO soft: apply U1 < 60 min em condições normais de conta

C) Other (please describe after [Answer]: tag below)

[Answer]: A (sem SLO formal; aceitar tempos típicos de create/apply)

### Question 3 — Disponibilidade

A) Best-effort PoC (single NAT = SPOF consciente); sem RTO/RPO formais

B) Documentar RTO soft (ex.: recriar stack < 2h) sem HA multi-NAT

C) Other (please describe after [Answer]: tag below)

[Answer]: A (best-effort PoC; single NAT como SPOF consciente)

### Question 4 — Segurança (U1)

A) Least privilege + BPA + sem secrets no repo; UI PUBLIC aceita com aviso no README (já decidido)

B) Mesmo que A + forçar encryption SSE-S3 (ou SSE-KMS) no ArtifactBucket

C) Other (please describe after [Answer]: tag below)

[Answer]: B (least privilege + BPA + SSE forçado no ArtifactBucket)

### Question 5 — Stack tecnológica (fixar)

A) Terraform >= 1.5 + AWS provider ~> 5.0; state local; AWS CLI para ops (recomendado)

B) Terraform >= 1.5 + AWS provider ~> 5.0 + backend S3 (mudaria decisão anterior de state local)

C) Other (please describe after [Answer]: tag below)

[Answer]: A (Terraform >= 1.5 + AWS ~> 5.0; state local; AWS CLI)

### Question 6 — Confiabilidade / observabilidade U1

A) Depender de status MWAA + CloudWatch logs nativos; sem alarmes SNS nesta unidade

B) Alarmes CloudWatch mínimos (MWAA failed / unhealthy) → SNS (antecipa U4 topic ou tópico temp)

C) Other (please describe after [Answer]: tag below)

[Answer]: A (status MWAA + CloudWatch nativos; sem alarmes SNS em U1)

### Question 7 — Manutenibilidade

A) Módulos TF + comentários + README (init/plan/apply/destroy) + fmt/validate no Build

B) Mesmo que A + checklist de review IAM obrigatório antes do apply

C) Other (please describe after [Answer]: tag below)

[Answer]: B (módulos + README + fmt/validate + checklist de review IAM obrigatório)

### Question 8 — Usabilidade (operador)

A) README com passos claros; UI MWAA PUBLIC; vars com defaults sensatos

B) Além de A: script helper (`scripts/apply.sh` / `sync-dags.sh`) opcional

C) Other (please describe after [Answer]: tag below)

[Answer]: B (README + scripts helper apply.sh / sync-dags.sh)

---

## 3. Decisões capturadas

| # | Decisão |
|---|---|
| 1 | Documentar headroom (`mw1.medium` / 2 NAT) sem implementar |
| 2 | Sem SLO formal de desempenho |
| 3 | Disponibilidade best-effort; NAT = SPOF consciente |
| 4 | Least privilege + BPA + **SSE** no ArtifactBucket |
| 5 | Terraform >= 1.5 + AWS ~> 5.0; state local; AWS CLI |
| 6 | Observabilidade: status MWAA + CW logs; sem alarmes SNS em U1 |
| 7 | Manutenção: módulos + README + fmt/validate + **checklist IAM** |
| 8 | Usabilidade: README + scripts `apply.sh` / `sync-dags.sh` |

## 4. Aprovação do plano

**Status**: plano aprovado — artefatos gerados; aguardando aprovação dos Requisitos NFR U1
