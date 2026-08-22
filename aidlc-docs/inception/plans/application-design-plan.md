    # Application Design Plan

    **Projeto**: ia-dlc-mwaa  
    **Estágio**: INCEPTION — Design da Aplicação (Planejamento)  
    **Referências**: `requirements.md`, `stories.md`, `execution-plan.md`

    Preencha cada `[Answer]:` com a letra. Avise no chat quando concluir (`pronto`).

    ---

    ## 1. Checklist de artefatos (gerar após aprovação deste plano)

- [x] `aidlc-docs/inception/application-design/components.md`
- [x] `aidlc-docs/inception/application-design/component-methods.md`
- [x] `aidlc-docs/inception/application-design/services.md`
- [x] `aidlc-docs/inception/application-design/component-dependency.md`
- [x] `aidlc-docs/inception/application-design/application-design.md` (consolidado)
- [x] Validar consistência com FRs e US-01..US-10

    ---

    ## 2. Proposta de componentes (rascunho — validar nas perguntas)

    | Componente | Responsabilidade |
    |---|---|
    | NetworkFabric | VPC, subnets, IGW, NAT, rotas, SG MWAA |
    | ArtifactStore | Bucket S3 de DAGs/plugins/requirements |
    | DataLakeStore | Bucket/prefixos raw/processed/athena-results |
    | OrchestratorMWAA | Ambiente MWAA + logging + lifecycle ignore |
    | IdentityPlane | Roles/policies MWAA, Lambda, Glue, ECS, Crawler, apply-policy doc |
    | ServerlessExecutor | Lambda de exemplo |
    | EtlExecutor | Glue Job + script/ref |
    | CatalogService | Glue Database + Crawler |
    | ContainerExecutor | ECS cluster + task Fargate |
    | GovernancePlane | Lake Formation locations, LF-Tags, grants |
    | QueryService | Athena workgroup + output location |
    | NotifyService | SNS topic (+ subscription opcional) |
    | PipelineApp | DAG Airflow de exemplo (código app, não TF puro) |

    ---

    ## 3. Perguntas de design

    ### Question 1 — Organização do Terraform (limites de componente no código)

    A) Um único root module (`terraform/`) com arquivos por domínio (`network.tf`, `mwaa.tf`, …) — mais simples para PoC

    B) Root + módulos internos (`modules/network`, `modules/mwaa`, …) — melhor isolamento, um pouco mais verboso

    C) Múltiplos roots/states por unidade (U1..U4) — máximo isolamento, mais overhead de apply

    D) Other (please describe after [Answer]: tag below)

    [Answer]: B (Root + módulos internos)

    ### Question 2 — Como modelar a “camada de serviço” neste projeto IaC

    A) Serviço lógico = orquestração via **DAG MWAA** (PipelineApp); Terraform só provisiona dependências

    B) Serviços espelham APIs AWS (cada executor é um “serviço”); DAG só cliente fino

    C) Híbrido: Terraform define *capability services*; DAG é o *orchestration service* (recomendado)

    D) Other (please describe after [Answer]: tag below)

    [Answer]: C (Híbrido: Terraform define capability services; DAG é o orchestration service)

    ### Question 3 — Acoplamento IdentityPlane

    A) Um `iam.tf` central com todas as roles/policies (mais fácil de revisar least privilege)

    B) IAM colado em cada arquivo de serviço (`lambda.tf` traz role da Lambda, etc.)

    C) Híbrido: roles de execução junto do serviço; policies de cross-service (MWAA→Lambda/Glue/ECS) no IdentityPlane central

    D) Other (please describe after [Answer]: tag below)

    [Answer]: C (Híbrido: roles de execução junto do serviço; policies cross-service no IdentityPlane central)

    ### Question 4 — Lake Formation vs Data Lake

    A) GovernancePlane separado de DataLakeStore/CatalogService (recomendado — US-08 explícita)

    B) Fundir governança dentro de DataLakeStore (menos arquivos, fronteira menos clara)

    C) Other (please describe after [Answer]: tag below)

    [Answer]: A (GovernancePlane separado)

    ### Question 5 — Diagrama de dependência no design

    A) Mermaid + ASCII (ambos)

    B) Só Mermaid

    C) Só ASCII

    D) Other (please describe after [Answer]: tag below)

    [Answer]: A (Mermaid + ASCII)

    ### Question 6 — Nível de detalhe em `component-methods.md`

    A) Métodos = operações Terraform/AWS de alto nível (ex.: `create_environment`, `invoke_lambda`) sem lógica interna

    B) Incluir também “métodos” do DAG (tasks Airflow) como interface do PipelineApp

    C) A + B (recomendado para fechar US-05..US-09)

    D) Other (please describe after [Answer]: tag below)

    [Answer]: C (A + B)

    ---

## 4. Decisões capturadas

| # | Decisão |
|---|---|
| 1 | Root + módulos internos (`modules/*`) |
| 2 | Híbrido: capability services (TF) + orchestration service (DAG) |
| 3 | IAM híbrido: roles no serviço; policies cross-service no IdentityPlane |
| 4 | GovernancePlane separado |
| 5 | Diagramas Mermaid + ASCII |
| 6 | Methods = ops TF/AWS + tasks do DAG (PipelineApp) |

## 5. Aprovação do plano

**Status**: plano aprovado (`provar plano de design` em 2026-08-21T22:07:00Z) — artefatos gerados

Aguardando aprovação dos artefatos de design no chat.
