# U3 Compute Executors — Domain Entities

## Entity Catalog

### PlatformContext (from U1)
- **Attributes**: `name_prefix`, `region`, `vpc_id`, `private_subnet_ids`, `mwaa_execution_role_arn`, `artifact_bucket_name`
- **Role**: Inputs de rede/identidade/artefatos para U3

### LakeContext (from U2)
- **Attributes**: `data_lake_bucket_name`, `glue_database_name`, prefixes `raw/`, `processed/`
- **Role**: Destino de markers e I/O do Glue Job

### ServerlessExecutor
- **Attributes**: `function_name`, `function_arn`, `role_arn`, `runtime`, `handler`, `marker_key_pattern`
- **Behavior**: Invoke → PutObject marker em raw
- **Collaborates with**: LakeContext, MwaaComputeGateway

### EtlExecutor
- **Attributes**: `job_name`, `role_arn`, `script_s3_uri`, `source_prefix`, `target_prefix`
- **Behavior**: StartJobRun → raw → processed Parquet by `dt`
- **Collaborates with**: LakeContext, ArtifactStore (U1), MwaaComputeGateway

### ContainerExecutor
- **Attributes**: `cluster_arn`, `task_definition_arn`, `task_role_arn`, `execution_role_arn`, `security_group_id`, `subnet_ids`, `image`, `marker_key_pattern`
- **Behavior**: RunTask Fargate → CLI PutObject marker
- **Collaborates with**: PlatformContext (network), LakeContext, MwaaComputeGateway

### MwaaComputeGateway
- **Attributes**: attached policy statements on MWAA execution role
- **Behavior**: Authorize invoke/start/run + PassRole scoped
- **Invariant**: No orchestration logic

### ExecutionMarker
- **Attributes**: `source` ∈ {lambda, ecs}, `dt`, `run_id?`, `timestamp`, `status`
- **Persistence**: JSON object on data lake under Hive-style `dt=`
- **Consumers**: Optional crawler/Athena later; primarily demo evidence

### GlueOutputPartition
- **Attributes**: `dt`, `format=parquet`, `location` under `processed/`
- **Produced by**: EtlExecutor

## Relationships

```
PlatformContext ----provides----> ServerlessExecutor
PlatformContext ----provides----> ContainerExecutor
LakeContext --------provides----> ServerlessExecutor / EtlExecutor / ContainerExecutor
ServerlessExecutor --writes----> ExecutionMarker (raw)
EtlExecutor --------writes----> GlueOutputPartition (processed)
ContainerExecutor --writes----> ExecutionMarker (raw|processed)
MwaaComputeGateway -authorizes-> ServerlessExecutor / EtlExecutor / ContainerExecutor
```

## Module Mapping (preview)

| Domain | Terraform module (Q9=A) |
|---|---|
| ServerlessExecutor | `lambda_executor` |
| EtlExecutor | `glue_job` |
| ContainerExecutor | `ecs_executor` |
| MwaaComputeGateway | root IAM policy on U1 role |

## Out of Domain (U3)
- DAG tasks, SNS topics, Athena queries as first-class entities → U4
- LF tag mutation by jobs → not required for PoC markers
