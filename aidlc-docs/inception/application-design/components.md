# Components

**Projeto**: ia-dlc-mwaa  
**Organização de código**: root Terraform + `modules/*`  
**Governança**: GovernancePlane separado  

> **Amendment (EC2 orchestrator)**: Default runtime is **OrchestratorEC2** (`orchestrator_mode=ec2`). OrchestratorMWAA only when `orchestrator_mode=mwaa`.

## Component Catalog

### NetworkFabric
- **Purpose**: Rede do lab (NAT para privados; pública para orquestrador EC2 / egress).
- **Responsibilities**: VPC, DNS, 2 subnets privadas, 1 pública, IGW, NAT, route tables; SG MWAA (modo mwaa); **SG Airflow EC2** (ingress 8080 de `operator_cidr`; sem 22 — SSM only).
- **Interfaces**: Exporta subnet IDs, VPC ID, SG IDs para OrchestratorEC2 / OrchestratorMWAA e ContainerExecutor.
- **TF module**: `modules/network`

### ArtifactStore
- **Purpose**: Armazenar DAGs, plugins, requirements e **artefatos Compose/bootstrap** do Airflow EC2.
- **Responsibilities**: Bucket versionado, BPA; prefixos `dags/`, `plugins/`, `requirements.txt`, `airflow-ec2/` (compose + bootstrap).
- **Interfaces**: Bucket ARN/name para OrchestratorEC2 (download no boot + DagSyncAgent), OrchestratorMWAA (modo mwaa), sync externo.
- **TF module**: `modules/artifact_store`

### DataLakeStore
- **Purpose**: Armazenamento do data lake de aprendizado.
- **Responsibilities**: Bucket (ou prefixos) `raw/`, `processed/`, `athena-results/`; versionamento; BPA.
- **Interfaces**: Bucket ARN/paths para CatalogService, EtlExecutor, GovernancePlane, QueryService.
- **TF module**: `modules/data_lake`

### OrchestratorEC2 (default)
- **Purpose**: Airflow 2.11.2 self-hosted em EC2 + Docker Compose (lab / Free Tier).
- **Responsibilities**: EC2 `t3.medium` Amazon Linux 2023 na subnet pública; instance profile; `user_data` baixa Compose do ArtifactStore e sobe stack (LocalExecutor + Postgres no Compose); UI `:8080`; SSM Session Manager (sem key pair); IP público dinâmico (sem EIP); scripts stop/start.
- **Interfaces**: Role `airflow-ec2-execution` (IdentityPlane); ArtifactStore; NetworkFabric SG; consome Serverless/Etl/Container/Query/Notify via instance role.
- **TF module**: `modules/airflow_ec2`
- **When**: `orchestrator_mode = "ec2"`

### OrchestratorMWAA (optional)
- **Purpose**: Ambiente gerenciado Apache Airflow.
- **Responsibilities**: `aws_mwaa_environment` (`mw1.small`, `airflow_version` default `2.11.2`, `PUBLIC_ONLY`), logs CloudWatch, lifecycle ignore em versions de requirements/plugins.
- **Interfaces**: Execution role MWAA (IdentityPlane), network, artifact bucket.
- **TF module**: `modules/mwaa`
- **When**: `orchestrator_mode = "mwaa"` only (não cria role/ambiente MWAA no modo ec2)

### IdentityPlane
- **Purpose**: Cross-service IAM least privilege + documentação da policy de `terraform apply`.
- **Responsibilities**: Role **`…-airflow-ec2-execution`** + instance profile + SSM core (modo ec2); policies lake/compute/SNS/Athena no principal ativo; role MWAA **somente** no modo mwaa; `policies/terraform-apply-policy.json`.
- **Interfaces**: Policy documents anexáveis; não cria secrets/access keys na EC2.
- **TF module**: `modules/identity` (+ root policy wiring)

### DagSyncAgent (logical)
- **Purpose**: Manter `dags/` locais do Compose alinhados ao ArtifactStore.
- **Responsibilities**: Cron/systemd na EC2: `aws s3 sync` do prefixo `dags/` → volume Compose; operador usa `scripts/sync-dags.sh` do workstation.
- **Interfaces**: ArtifactStore → filesystem local do OrchestratorEC2.
- **TF module**: none (bootstrap no `airflow_ec2` / user_data)

### ServerlessExecutor
- **Purpose**: Executor leve de exemplo.
- **Responsibilities**: Lambda Python 3.12, role de execução mínima, log group.
- **Interfaces**: Function ARN para PipelineApp / orquestrador ativo.
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
- **Interfaces**: Cluster ARN, task definition ARN para PipelineApp.
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
- **Responsibilities**: DAG exemplo (Lambda + Glue + ECS + Athena + SNS); `requirements.txt`; instruções `aws s3 sync` + URL UI EC2.
- **Interfaces**: Código em `dags/`; deploy via sync para ArtifactStore → DagSyncAgent.
- **Location**: `dags/` + `requirements.txt` (workspace root)
