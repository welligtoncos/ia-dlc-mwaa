# Application Design (Consolidated)

## Summary
Design lógico da plataforma de dados AWS. **Default orchestrator**: EC2 `t3.medium` + Docker Compose Airflow 2.11.2 (Free Tier / custo controlado). MWAA permanece como modo opcional (`orchestrator_mode=mwaa`). Terraform root + modules; IAM híbrido; GovernancePlane separado.

## Architecture Decisions
| Decision | Choice |
|---|---|
| TF layout | Root + `modules/*` |
| Service model | Capability services + Pipeline orchestration |
| IAM | Local executor roles + central orchestrator policies |
| Lake Formation | Separate GovernancePlane |
| **Orchestrator default** | **OrchestratorEC2** — AL2023, Compose LocalExecutor + Postgres container, SSM-only, no EIP, UI :8080 + `operator_cidr` |
| Orchestrator optional | OrchestratorMWAA `mw1.small` when `orchestrator_mode=mwaa` |
| Module | `modules/airflow_ec2`; role `…-airflow-ec2-execution` |
| Compose delivery | Upload to ArtifactStore; user_data pulls |
| DAG deploy | `sync-dags.sh` → S3 → DagSyncAgent on EC2 |
| State | Local (PoC) |

## Components
Ver `components.md` — inclui **OrchestratorEC2**, **DagSyncAgent**; OrchestratorMWAA opcional.

## Methods
Ver `component-methods.md` — EC2 bootstrap, SSM, sync, dual-mode IdentityPlane.

## Services
Ver `services.md` — Orchestration Runtime default EC2; MWAA optional.

## Dependencies
Ver `component-dependency.md` — matriz e diagramas modo ec2.

## Mapping to User Stories (updated)
| US | Primary components |
|---|---|
| US-01 | NetworkFabric |
| US-02 | **OrchestratorEC2** (default) / OrchestratorMWAA (optional) |
| US-03 | ArtifactStore |
| US-04 | IdentityPlane (apply policy) |
| US-05 | PipelineApp + ArtifactStore + DagSyncAgent |
| US-06 | ServerlessExecutor + PipelineApp |
| US-07 | EtlExecutor + ContainerExecutor + CatalogService |
| US-08 | GovernancePlane + DataLakeStore |
| US-09 | QueryService + NotifyService |
| US-10 | IdentityPlane (EC2 role default) |

## Mapping to Requirements
Baseline FR-01..FR-14 + **FR-EC2-01..08** (`ec2-airflow-orchestrator-requirements.md`).

## Units
Ver `unit-of-work.md` — U1 delta inclui `airflow_ec2`; Units Generation skipped for this change.

## Next Stage
**CONSTRUCTION** — Functional Design for unit **U1-orchestrator-ec2**.
