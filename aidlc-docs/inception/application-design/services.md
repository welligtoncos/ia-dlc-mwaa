# Services

Modelo híbrido: **capability services** (Terraform) + **orchestration service** (DAG).

## Capability Services (infra)

| Service | Backing components | Offers |
|---|---|---|
| Networking Capability | NetworkFabric | Conectividade privada + egress NAT |
| Artifact Capability | ArtifactStore | Storage versionado para código Airflow |
| Lake Storage Capability | DataLakeStore | Storage de dados raw/processed/results |
| Catalog Capability | CatalogService | Metadados Glue |
| Governance Capability | GovernancePlane | LF locations, tags, grants |
| Query Capability | QueryService | Workgroup Athena |
| Compute: Serverless | ServerlessExecutor | Invoke sob demanda |
| Compute: ETL | EtlExecutor | Spark/Glue job runs |
| Compute: Container | ContainerExecutor | Fargate tasks |
| Messaging Capability | NotifyService | Publish de eventos de status |
| Identity Capability | IdentityPlane | Cross-service authZ + apply policy doc |
| Orchestration Runtime | OrchestratorMWAA | Airflow managed runtime |

## Orchestration Service

### PipelineOrchestrationService (PipelineApp + OrchestratorMWAA)
- **Responsibility**: Coordenar o fluxo E2E de aprendizado: sync → invoke Lambda → Glue → ECS → Athena → SNS.
- **Pattern**: Orchestrator (Airflow DAG) chama capabilities via AWS operators/hooks.
- **Does not**: Provisionar VPC/IAM (isso é Terraform).
- **Sequence**:
  1. Operator/Dev sincroniza artefatos (US-05)
  2. DAG dispara ServerlessExecutor
  3. DAG dispara EtlExecutor (+ opcional crawler trigger)
  4. DAG dispara ContainerExecutor
  5. DAG consulta QueryService (dados governados)
  6. DAG publica NotifyService

## Service Interaction Rules
- Terraform cria capabilities **antes** do primeiro sync de DAG.
- MWAA execution role só recebe ações das capabilities do stack (IdentityPlane).
- Governance Capability é caminho obrigatório para leitura controlada via Athena/Glue.
- Nenhum capability service usa `AdministratorAccess` ou `Action="*"`.
