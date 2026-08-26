# Services

Modelo híbrido: **capability services** (Terraform) + **orchestration service** (DAG).

> **Amendment**: Orchestration Runtime default = EC2 Compose; MWAA opcional via `orchestrator_mode`.

## Capability Services (infra)

| Service | Backing components | Offers |
|---|---|---|
| Networking Capability | NetworkFabric | Privado + NAT; pública + SG UI EC2 |
| Artifact Capability | ArtifactStore | Storage versionado (DAGs + compose package) |
| Lake Storage Capability | DataLakeStore | Storage de dados raw/processed/results |
| Catalog Capability | CatalogService | Metadados Glue |
| Governance Capability | GovernancePlane | LF locations, tags, grants |
| Query Capability | QueryService | Workgroup Athena |
| Compute: Serverless | ServerlessExecutor | Invoke sob demanda |
| Compute: ETL | EtlExecutor | Spark/Glue job runs |
| Compute: Container | ContainerExecutor | Fargate tasks |
| Messaging Capability | NotifyService | Publish de eventos de status |
| Identity Capability | IdentityPlane | Role EC2 (default) ou MWAA (opcional) + apply policy doc |
| Orchestration Runtime (default) | OrchestratorEC2 + DagSyncAgent | Airflow 2.11.2 on EC2 Compose |
| Orchestration Runtime (optional) | OrchestratorMWAA | Airflow managed (mode=mwaa) |

## Orchestration Service

### PipelineOrchestrationService (PipelineApp + active orchestrator)
- **Responsibility**: Coordenar o fluxo E2E: sync → Lambda → Glue → ECS → Athena → SNS.
- **Pattern**: Airflow DAG chama capabilities via AWS operators/hooks; credenciais = **instance role** (modo ec2) ou MWAA execution role (modo mwaa).
- **Does not**: Provisionar VPC/IAM (Terraform).
- **Sequence**:
  1. Operator sincroniza artefatos (`sync-dags.sh`)
  2. DagSyncAgent na EC2 puxa `dags/` (modo ec2)
  3. DAG dispara ServerlessExecutor → EtlExecutor → ContainerExecutor → QueryService → NotifyService

## Service Interaction Rules
- Terraform cria capabilities **antes** do primeiro sync de DAG.
- Principal ativo (`airflow-ec2-execution` ou MWAA role) só recebe ações das capabilities do stack.
- Modo `ec2`: **não** provisiona role/ambiente MWAA.
- Nenhum capability service usa `AdministratorAccess` ou `Action="*"`.
- UI Airflow: SG 8080 restrito a `operator_cidr`; acesso shell via SSM.
