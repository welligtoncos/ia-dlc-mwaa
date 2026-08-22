
# Story Generation Plan

**Projeto**: ia-dlc-mwaa  
**Estágio**: INCEPTION — Histórias de Usuário (Parte 1 — Planejamento)  
**Referência**: `aidlc-docs/inception/requirements/requirements.md`

Responda cada pergunta preenchendo a letra após `[Answer]:`.  
Quando todas estiverem preenchidas, avise no chat (`pronto` / `done`).

---

## 1. Avaliação (concluída)

- [x] Documentar avaliação em `user-stories-assessment.md`
- [x] Decisão: **executar** histórias de usuário

---

## 2. Metodologia proposta

### 2.1 Abordagens de decomposição (escolha)

| Abordagem | Benefício | Trade-off |
|---|---|---|
| Jornada do usuário | Espelha aprendizado E2E | Pode misturar domínios TF |
| Funcionalidade | Alinha a arquivos TF (network, mwaa, glue…) | Menos narrativa |
| Persona | Separa Platform vs Data | Duplicação entre papéis |
| Domínio | Orquestração / Lake / Compute | Fronteiras subjetivas |
| Epic | Hierarquia clara | Overhead em PoC |

**Recomendação do product owner**: híbrido **Epic + Jornada** (epics por domínio; histórias na ordem do fluxo de aprendizado).

### Question 1 — Abordagem de decomposição

A) Híbrido Epic + Jornada (recomendado)

B) Por funcionalidade / arquivo Terraform

C) Por persona (Platform vs Data)

D) Other (please describe after [Answer]: tag below)

[Answer]: A (Híbrido Epic + Jornada)

### Question 2 — Personas a gerar

A) Duas: Platform Engineer + Data Engineer (recomendado)

B) Três: Platform + Data + Security/Governance

C) Uma só: Learner (papel único de aprendizado)

D) Other (please describe after [Answer]: tag below)

[Answer]: B (Platform + Data + Security/Governance)

### Question 3 — Granularidade

A) ~8–12 histórias médias com AC objetivos (recomendado para escopo B)

B) ~5–7 histórias épicas mais amplas

C) ~15+ histórias pequenas (uma por recurso AWS)

D) Other (please describe after [Answer]: tag below)

[Answer]: A (~8–12 histórias médias)

### Question 4 — Formato dos critérios de aceitação

A) Given / When / Then

B) Checklist bullet (pass/fail)

C) Mistura: GWT para jornadas E2E + checklist para infra TF

D) Other (please describe after [Answer]: tag below)

[Answer]: C (GWT para jornadas E2E + checklist para infra TF)

### Question 5 — Prioridade das histórias no documento

A) Ordem de jornada E2E (provisionar → sync DAG → executar → governar → consultar → notificar)

B) Ordem de dependência Terraform (network → iam → s3 → …)

C) Sem priorização explícita (só agrupamento por epic)

D) Other (please describe after [Answer]: tag below)

[Answer]: A (ordem de jornada E2E)

### Question 6 — Idioma dos artefatos `stories.md` / `personas.md`

A) Português (recomendado; alinhado à conversa)

B) Inglês

C) Other (please describe after [Answer]: tag below)

[Answer]: A (Português)

---

## 3. Checklist de geração (Parte 2 — após aprovação deste plano)

Não execute ainda. Será marcado `[x]` na Parte 2.

- [x] Criar `aidlc-docs/inception/user-stories/personas.md`
- [x] Criar `aidlc-docs/inception/user-stories/stories.md` (INVEST + AC)
- [x] Mapear personas → histórias
- [x] Cobrir FRs: MWAA, rede, S3 DAGs, data lake, Glue Catalog/Crawler/Job, Lambda, ECS, Lake Formation/LF-Tags, Athena, SNS, IAM least privilege, política terraform apply, sync de DAGs
- [x] Revisar INVEST e consistência com `requirements.md`
- [x] Apresentar histórias para aprovação do usuário

---

## 4. Decisões capturadas (respostas)

| # | Decisão |
|---|---|
| 1 | Híbrido Epic + Jornada |
| 2 | 3 personas: Platform + Data + Security/Governance |
| 3 | ~8–12 histórias médias |
| 4 | AC mistos: GWT (E2E) + checklist (infra TF) |
| 5 | Prioridade por jornada E2E |
| 6 | Artefatos em Português |

## 5. Aprovação do plano

**Status**: plano aprovado em 2026-08-21T21:56:30Z — Parte 2 concluída

Artefatos gerados:
- `aidlc-docs/inception/user-stories/personas.md`
- `aidlc-docs/inception/user-stories/stories.md`
