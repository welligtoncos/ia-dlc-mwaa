# Unit of Work Plan

**Projeto**: ia-dlc-mwaa  
**Estágio**: INCEPTION — Geração de Unidades (Parte 1 — Planejamento)  
**Tipo**: Greenfield · Terraform root + modules · 4 unidades propostas no execution-plan

Preencha cada `[Answer]:` com a letra. Avise no chat quando concluir (`pronto`).

---

## 1. Checklist de geração (Parte 2 — após aprovação deste plano)

- [x] Gerar `aidlc-docs/inception/application-design/unit-of-work.md`
- [x] Gerar `aidlc-docs/inception/application-design/unit-of-work-dependency.md`
- [x] Gerar `aidlc-docs/inception/application-design/unit-of-work-story-map.md`
- [x] Documentar estratégia de organização de código (greenfield) em `unit-of-work.md`
- [x] Validar limites/dependências e cobertura de US-01..US-10
- [x] Apresentar unidades para aprovação

---

## 2. Proposta inicial de unidades

| Unit | Nome | Componentes | Stories |
|---|---|---|---|
| U1 | Foundation | NetworkFabric, ArtifactStore, OrchestratorMWAA, IdentityPlane (base MWAA + apply policy) | US-01..US-04, parte US-10 |
| U2 | Data Lake and Governance | DataLakeStore, CatalogService, GovernancePlane, QueryService | US-08, US-09 (Athena), parte lake |
| U3 | Compute Executors | ServerlessExecutor, EtlExecutor, ContainerExecutor + grants MWAA→compute | US-06, US-07, parte US-10 |
| U4 | Orchestration and Notify | PipelineApp (DAG/requirements), NotifyService, docs sync | US-05, US-09 (SNS), fechamento E2E |

**Apply**: um único `terraform apply` no root (módulos internos), na ordem de dependência lógica U1→U2→U3→U4 no grafo de módulos — não 4 states separados (alinhado à decisão Q1 do Application Design = root+modules).

---

## 3. Perguntas

### Question 1 — Agrupamento de histórias / número de unidades

A) Manter **4 unidades** da proposta (recomendado)

B) **3 unidades**: fundir U3+U4 (Compute+Orchestration)

C) **2 unidades**: Foundation+MWAA vs Lake+Compute+DAG

D) Other (please describe after [Answer]: tag below)

[Answer]: A (manter 4 unidades)

### Question 2 — Dependências entre unidades

A) Grafo estrito U1 → U2 → U3 → U4 (U4 por último; DAG só após capabilities)

B) U1 → (U2 ∥ U3) → U4 (lake e compute em paralelo após foundation)

C) Other (please describe after [Answer]: tag below)

[Answer]: B (U1 → (U2 ∥ U3) → U4)

### Question 3 — Alinhamento de ownership (mesmo sendo PoC solo)

A) Documentar ownership lógico por persona (P1→U1, P3→U2, P2→U3/U4) sem separar repos

B) Sem ownership por persona — uma unidade “plataforma” só com split técnico

C) Other (please describe after [Answer]: tag below)

[Answer]:A (ownership lógico por persona, sem separar repos)

### Question 4 — Considerações técnicas de deploy

A) Um root Terraform, um state local, um apply — modules espelham unidades (recomendado)

B) Um root, mas workspaces/tfvars por unidade (só organização de vars)

C) Other (please describe after [Answer]: tag below)

[Answer]: A (um root, um state local, um apply; módulos espelham unidades)

### Question 5 — Domínio de negócio (bounded context)

A) Contextos: Platform (U1), Governance/Lake (U2), Compute (U3), Orchestration (U4)

B) Contextos: Control Plane (U1+U4) vs Data Plane (U2+U3)

C) Other (please describe after [Answer]: tag below)

[Answer]: A (Platform / Governance-Lake / Compute / Orchestration)

### Question 6 — Organização de código (greenfield)

A) `terraform/` (root + `modules/<unit-aligned>`) + `dags/` + `policies/` + `README.md` (recomendado)

B) Tudo na raiz do repo (`network.tf`, `modules/`, `dags/`) sem pasta `terraform/`

C) Other (please describe after [Answer]: tag below)

[Answer]: A (terraform/ + dags/ + policies/ + README.md)

---

## 4. Decisões capturadas

| # | Decisão |
|---|---|
| 1 | 4 unidades (U1–U4) |
| 2 | Dependências: U1 → (U2 ∥ U3) → U4 |
| 3 | Ownership lógico por persona (P1→U1, P3→U2, P2→U3/U4) |
| 4 | Um root TF, state local, um apply; modules alinhados às unidades |
| 5 | Bounded contexts: Platform / Governance-Lake / Compute / Orchestration |
| 6 | Layout: `terraform/` + `dags/` + `policies/` + `README.md` |

## 5. Aprovação do plano

**Status**: plano aprovado — artefatos gerados; aguardando aprovação das unidades no chat
