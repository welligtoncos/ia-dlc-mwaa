# U2 Data Lake and Governance — Functional Design Plan

**Unidade**: U2 Data Lake and Governance  
**Stories**: US-08, US-09 (parte Athena)  
**Depende de**: U1 (prefixo/tags/provider; bucket artefatos MWAA já existe — lake é bucket separado)  
**Foco**: lógica de lake/governança/consulta (agnóstico a detalhe TF até Infrastructure Design)

Preencha cada `[Answer]:` e avise (`pronto`).

---

## 1. Checklist de artefatos (após aprovação deste plano)

- [x] `business-logic-model.md`
- [x] `business-rules.md`
- [x] `domain-entities.md`
- [x] Validar cobertura US-08 + Athena (US-09 parcial)
- [x] Apresentar para aprovação

---

## 2. Escopo da unidade

U2 provisiona:
- Data lake S3 (`raw/`, `processed/`, `athena-results/`)
- Glue Database + Crawler
- Lake Formation (location, LF-Tags, grants mínimos)
- Athena workgroup

**Não inclui**: Lambda/Glue Job/ECS (U3), DAG/SNS (U4), rede/MWAA (U1).

---

## 3. Perguntas

### Question 1 — Layout do data lake

A) **Um bucket** de lake com prefixos `raw/`, `processed/`, `athena-results/` (recomendado PoC)

B) Dois buckets: dados (`raw`/`processed`) + resultados Athena separado

C) Other (please describe after [Answer]: tag below)

[Answer]: B (dois buckets: dados + resultados Athena separados)

### Question 2 — Modelo de governança Lake Formation

A) LF-Tags mínimos: `Classification` (`raw`|`processed`) + `Project` (`ia-dlc-mwaa`) + grants ao execution role MWAA e role de crawler/Athena (recomendado)

B) Só register location + grant amplo `ALL` no database (mais simples, menos didático)

C) Other (please describe after [Answer]: tag below)

[Answer]: A (LF-Tags mínimos: Classification + Project + grants direcionados)

### Question 3 — Catalog / Crawler

A) Glue Database único + **1 crawler** apontando para `raw/` (recomendado lab)

B) Dois crawlers (`raw/` e `processed/`)

C) Other (please describe after [Answer]: tag below)

[Answer]: B (dois crawlers: raw/ e processed/)

### Question 4 — Athena workgroup

A) Workgroup `dev` com output em `s3://<lake>/athena-results/` e enforce workgroup config (recomendado)

B) Usar workgroup `primary` default da conta (menos isolamento)

C) Other (please describe after [Answer]: tag below)

[Answer]: A (workgroup dev com output próprio e enforce)

### Question 5 — Dados de exemplo para o lab

A) Terraform **não** sobe dataset; documentar upload manual/sample em `raw/` (recomendado — separa infra de dados)

B) Terraform faz upload de 1 CSV de exemplo em `raw/` via `aws_s3_object`

C) Other (please describe after [Answer]: tag below)

[Answer]: A (Terraform não sobe dataset; upload manual documentado)

### Question 6 — Pré-requisito Lake Formation admin

A) Documentar no README que a conta precisa de **Data Lake administrator** já configurado (pré-req manual)

B) Terraform tenta setar LF admins via recurso (pode ser disruptivo em contas existentes)

C) Other (please describe after [Answer]: tag below)

[Answer]: A (documentar Data Lake admin como pré-requisito manual)

### Question 7 — Integração com U1 / MWAA

A) Grants LF + IAM mínimos para a **execution role do MWAA** consultar Athena/Catalog no lake (preparar U4)

B) Só roles locais do crawler/Athena agora; MWAA recebe grants só na U4

C) Other (please describe after [Answer]: tag below)

[Answer]: A (já preparar grants LF+IAM para a execution role do MWAA)

---

## 4. Decisões capturadas

| # | Decisão |
|---|---|
| 1 | **Dois buckets**: dados (`raw/`/`processed/`) + resultados Athena separado |
| 2 | LF-Tags `Classification` + `Project` + grants direcionados |
| 3 | **Dois crawlers** (`raw/` e `processed/`) |
| 4 | Workgroup Athena `dev` com enforce; **output no bucket de resultados** (não prefixo no bucket de dados — alinhado à Q1=B) |
| 5 | Sem dataset no Terraform; upload manual documentado |
| 6 | Data Lake administrator = pré-requisito manual (README) |
| 7 | Já preparar grants LF+IAM para execution role MWAA (U4) |

## 5. Aprovação do plano

**Status**: plano aprovado — artefatos gerados; aguardando aprovação do Design Funcional U2
