# U4-orchestration-notify — Logical NFR Components

## Component Catalog

### NotifyTopic
- **Responsibility**: Destino SNS de status da pipeline E2E.
- **Implements**: Tópico SNS; subscription e-mail opcional (`sns_notification_email` vazio = skip).
- **Collaborates with**: TopicAccessPolicy, PipelineNotify via DAG.
- **Infra mapping**: `modules/sns` (topic + optional subscription); outputs ARN/name.

### TopicAccessPolicy
- **Responsibility**: Restringir quem pode publicar no tópico.
- **Implements**: SNS topic policy Allow `sns:Publish` **somente** ao ARN do role EC2 orquestrador.
- **Collaborates with**: NotifyTopic, OrchestratorPublishGrant.
- **Infra mapping**: `aws_sns_topic_policy` no módulo SNS (recebe role ARN).

### OrchestratorPublishGrant
- **Responsibility**: Identity-side least privilege para publish + Athena/Glue reads.
- **Implements**: Policy anexada ao role `…-airflow-ec2-execution`: `sns:Publish` no ARN do tópico; Athena mínimo; `athena:GetWorkGroup`; `glue:GetTable` se necessário.
- **Collaborates with**: NotifyTopic, U2 Athena/Glue, PipelineApp.
- **Infra mapping**: IAM policy no módulo identity EC2 ou root wiring U4.

### ProviderRuntime
- **Responsibility**: Garantir `apache-airflow-providers-amazon` no runtime Compose.
- **Implements**: `requirements.txt` pinado; bootstrap **pip install -r** no volume compartilhado antes/junto do compose up; documentar restart após mudança de requirements.
- **Collaborates with**: BootstrapAgent (U1), ArtifactStore.
- **Infra mapping**: update `bootstrap.sh` / compose package objects; sync requirements path.

### VariableBindingTool
- **Responsibility**: Mapear outputs Terraform → Airflow Variables sem API remota.
- **Implements**: `scripts/set-airflow-variables.ps1` (+ `.sh`): lê `terraform output -json`, imprime comandos `airflow variables set <key> <value>` para colar via SSM.
- **Collaborates with**: OperatorE2EGuide, ResourceBinding (FD).
- **Infra mapping**: scripts na raiz `scripts/` (não recurso AWS).

### PipelineReliabilityPolicy
- **Responsibility**: Defaults de retry/timeout/concurrency do DAG.
- **Implements**: `retries=1`, `retry_delay=60s`; timeouts Lambda 5m / Glue 45m / ECS 30m / Athena 15m / SNS 2m; `max_active_runs=1`; `catchup=False`.
- **Collaborates with**: PipelineApp DAG code.
- **Infra mapping**: código em `dags/lab_pipeline_e2e.py`.

### OperatorE2EGuide
- **Responsibility**: UX operacional E2E + custo marginal.
- **Implements**: Seções em README + `docs/lab-guide.md`: start EC2, sync DAGs, set variables (SSM paste), trigger, verify SNS/Athena, stop; nota ~centavos SNS/Athena; RTO = start time.
- **Collaborates with**: VariableBindingTool, NotifyTopic, CostGuardrail (U1).

## Logical View

```text
terraform outputs
       |
       v
VariableBindingTool ---> (SSM paste) ---> Airflow Variables
                                              |
                                              v
BootstrapAgent + ProviderRuntime ---> Compose Airflow 2.11.2
                                              |
                                              v
PipelineReliabilityPolicy + lab_pipeline_e2e
       |              |              |
       v              v              v
   U3 executors    Athena U2    NotifyTopic
                                      ^
                                      |
                         TopicAccessPolicy
                         OrchestratorPublishGrant
```

## Collaboration with U1 NFR components
| U1 component | U4 interaction |
|---|---|
| BootstrapAgent | Estendido por ProviderRuntime (pip requirements) |
| IdentityBoundary | Recebe OrchestratorPublishGrant |
| HealthMonitor | Permanece **sem** SNS U4 |
| DagSyncAgent | Continua sync de `dags/` (incl. E2E DAG) |
| OperatorTooling | Complementado por VariableBindingTool + OperatorE2EGuide |
