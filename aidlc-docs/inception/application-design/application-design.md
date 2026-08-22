# Application Design (Consolidated)

## Summary
Design lógico da plataforma de dados AWS orquestrada por MWAA para aprendizado E2E (escopo completo). Terraform em **root + modules**; serviços em modelo **híbrido** (capabilities TF + orchestration DAG); IAM **híbrido**; **GovernancePlane** separado; diagramas Mermaid+ASCII; methods cobrem ops TF e tasks do DAG.

## Architecture Decisions
| Decision | Choice |
|---|---|
| TF layout | Root + `modules/*` |
| Service model | Capability services + Pipeline orchestration |
| IAM | Local executor roles + central cross-service policies |
| Lake Formation | Separate GovernancePlane |
| MWAA | `mw1.small`, `airflow_version` default `2.11.2`, web `PUBLIC` |
| DAG deploy | Outside Terraform (`aws s3 sync`) |
| State | Local (PoC) |

## Components
Ver `components.md` — 13 componentes: NetworkFabric, ArtifactStore, DataLakeStore, OrchestratorMWAA, IdentityPlane, ServerlessExecutor, EtlExecutor, CatalogService, ContainerExecutor, GovernancePlane, QueryService, NotifyService, PipelineApp.

## Methods
Ver `component-methods.md` — operações de provisionamento por módulo + tasks do DAG (Lambda, Glue, ECS, Athena, SNS).

## Services
Ver `services.md` — capability services mapeados 1:1 aos módulos; PipelineOrchestrationService como orquestrador.

## Dependencies
Ver `component-dependency.md` — matriz, mermaid e ASCII.

## Mapping to User Stories
| US | Primary components |
|---|---|
| US-01 | NetworkFabric |
| US-02 | OrchestratorMWAA |
| US-03 | ArtifactStore |
| US-04 | IdentityPlane (apply policy) |
| US-05 | PipelineApp + ArtifactStore |
| US-06 | ServerlessExecutor + PipelineApp |
| US-07 | EtlExecutor + ContainerExecutor + CatalogService |
| US-08 | GovernancePlane + DataLakeStore |
| US-09 | QueryService + NotifyService |
| US-10 | IdentityPlane (+ all executor roles) |

## Mapping to Requirements
FR-01..FR-14 cobertos pelos componentes acima; NFR least-privilege e tags padrão aplicados via IdentityPlane + convenção de módulos.

## Next Stage
Units Generation — decompor em U1 Foundation, U2 Lake/Governance, U3 Compute, U4 Orchestration/Notify (conforme execution-plan).
