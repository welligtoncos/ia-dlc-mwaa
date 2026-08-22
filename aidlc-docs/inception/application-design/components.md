# Components

**Projeto**: ia-dlc-mwaa  
**Organização de código**: root Terraform + `modules/*`  
**Governança**: GovernancePlane separado

## Component Catalog

### NetworkFabric
- **Purpose**: Rede mínima exigida pelo MWAA (saída à internet via 1 NAT).
- **Responsibilities**: VPC, DNS, 2 subnets privadas, 1 pública, IGW, NAT, route tables, security group MWAA.
- **Interfaces**: Exporta subnet IDs, VPC ID, SG ID para OrchestratorMWAA e ContainerExecutor.
- **TF module**: `modules/network`

### ArtifactStore
- **Purpose**: Armazenar DAGs, plugins e requirements do Airflow.
- **Responsibilities**: Bucket versionado, block public access, prefixos `dags/`, `plugins/`, `requirements.txt`.
- **Interfaces**: Bucket ARN/name para OrchestratorMWAA e sync externo (PipelineApp deploy).
- **TF module**: `modules/artifact_store`

### DataLakeStore
- **Purpose**: Armazenamento do data lake de aprendizado.
- **Responsibilities**: Bucket (ou prefixos) `raw/`, `processed/`, `athena-results/`; versionamento; BPA.
- **Interfaces**: Bucket ARN/paths para CatalogService, EtlExecutor, GovernancePlane, QueryService.
- **TF module**: `modules/data_lake`

### OrchestratorMWAA
- **Purpose**: Ambiente gerenciado Apache Airflow.
- **Responsibilities**: `aws_mwaa_environment` (`mw1.small`, `airflow_version` var default `2.11.2`, `PUBLIC`), logs CloudWatch, lifecycle ignore em versions de requirements/plugins.
- **Interfaces**: Execution role (via IdentityPlane), network, artifact bucket; consome Serverless/Etl/Container/Query/Notify via policies.
- **TF module**: `modules/mwaa`

### IdentityPlane
- **Purpose**: Cross-service IAM least privilege + documentação da policy de `terraform apply`.
- **Responsibilities**: Policies MWAA→executors/lake/SNS/Athena/LF; arquivo `policies/terraform-apply-policy.json` comentado.
- **Interfaces**: Policy documents anexáveis; não cria secrets.
- **Nota**: Roles de execução “locais” ficam nos módulos de cada executor (decisão Q3).
- **TF module**: `modules/identity` (+ arquivo de policy apply na raiz docs/policies)

### ServerlessExecutor
- **Purpose**: Executor leve de exemplo.
- **Responsibilities**: Lambda Python 3.12, role de execução mínima, log group.
- **Interfaces**: Function ARN para OrchestratorMWAA / PipelineApp.
- **TF module**: `modules/lambda_executor`

### EtlExecutor
- **Purpose**: Job ETL de exemplo.
- **Responsibilities**: Glue Job + role; referência a script; permissões S3 lake + Catalog.
- **Interfaces**: Job name/ARN para PipelineApp.
- **TF module**: `modules/glue_job`

### CatalogService
- **Purpose**: Metadados do lake.
- **Responsibilities**: Glue Database + Crawler + role do crawler.
- **Interfaces**: Database name, crawler name para GovernancePlane e QueryService.
- **TF module**: `modules/glue_catalog`

### ContainerExecutor
- **Purpose**: Executor container de exemplo.
- **Responsibilities**: ECS cluster, task definition Fargate, execution/task roles, SG/saída.
- **Interfaces**: Cluster ARN, task definition ARN para PipelineApp/MWAA.
- **TF module**: `modules/ecs_executor`

### GovernancePlane
- **Purpose**: Governança fine-grained Lake Formation.
- **Responsibilities**: Register location, LF-Tags, associações, grants mínimos a principals do stack.
- **Interfaces**: Tag keys/values; grants consumidos por QueryService/Etl/Orchestrator.
- **TF module**: `modules/lake_formation`

### QueryService
- **Purpose**: Consulta SQL ad-hoc/governada.
- **Responsibilities**: Athena workgroup `dev`, output em `athena-results/`.
- **Interfaces**: Workgroup name para PipelineApp.
- **TF module**: `modules/athena`

### NotifyService
- **Purpose**: Notificação de sucesso/falha do DAG.
- **Responsibilities**: SNS topic; subscription e-mail opcional (var).
- **Interfaces**: Topic ARN para PipelineApp / IdentityPlane publish.
- **TF module**: `modules/sns`

### PipelineApp
- **Purpose**: Aplicação de orquestração (não é recurso TF puro).
- **Responsibilities**: DAG exemplo (Lambda + Glue + ECS + Athena + SNS); `requirements.txt`; instruções `aws s3 sync`.
- **Interfaces**: Código em `dags/`; deploy via sync para ArtifactStore.
- **Location**: `dags/` + `requirements.txt` (workspace root), fora dos modules TF
