# U3 Compute Executors — Business Logic Model

## Purpose
Modelar o provisionamento e o comportamento dos **executors de compute** (Lambda, Glue Job, ECS Fargate) invocáveis pelo MWAA, sem detalhe Terraform.

## Primary Flow — Provision Compute Executors

```
1. Load PlatformContext from U1 (name_prefix, tags, region, vpc, private_subnets, mwaa_execution_role, artifact_bucket)
2. Load LakeContext from U2 (data_lake_bucket, glue_database, prefixes raw/processed)
3. Provision ServerlessExecutor (Lambda + role) — writes marker to raw/
4. Provision EtlExecutor (Glue Job + role + script on artifact bucket) — raw → processed Parquet
5. Provision ContainerExecutor (ECS cluster + Fargate task + roles + SG) — writes marker to lake via CLI
6. Attach Invoke/Start/Run grants on MWAA execution role (least privilege + PassRole)
7. Publish ComputeOutputs for U4 (ARNs, job name, cluster/task family)
```

## Capability Behaviors

### ServerlessExecutor (Lambda)
- Runtime Python 3.12; handler recebe evento Airflow.
- **Escreve marcador** em `s3://{data_lake}/raw/dt=YYYY-MM-DD/lambda_marker.json` (integra U2).
- Loga payload em CloudWatch; retorna status OK se PutObject ok.
- Empacotamento: zip local gerado no apply (`archive_file`).

### EtlExecutor (Glue Job)
- Script no **artifact bucket U1** (objeto versionado).
- **Passthrough**: lê sample/objetos sob `raw/`, grava Parquet particionado em `processed/dt=YYYY-MM-DD/`.
- Role própria: S3 lake (raw read, processed write) + Glue Catalog mínimo.
- Sem job bookmark agressivo; re-run PoC sobrescreve/particiona por `dt`.

### ContainerExecutor (ECS Fargate)
- Cluster ECS + task definition Fargate.
- Imagem **pública** (sem ECR); entrypoint usa AWS CLI para **escrever marcador** no lake (`raw/` ou `processed/` conforme env).
- Rede: **subnets privadas U1**, SG egress-only, **sem public IP** (pull via NAT U1).
- Roles: execution (logs/pull) + task (S3 Put no lake).

### MwaaComputeGateway (grants)
- Não orquestra; só autoriza MWAA a:
  - `lambda:InvokeFunction` na função U3
  - `glue:StartJobRun` + Get* no job U3
  - `ecs:RunTask` + Describe/Stop no cluster/task U3
  - `iam:PassRole` apenas nos roles ECS/Glue necessários
- Orquestração E2E = **U4**.

## Logical Data Contract (for U4)

```
Lambda marker → s3://data/raw/dt=.../lambda_marker.json
Glue output   → s3://data/processed/dt=.../*.parquet
ECS marker    → s3://data/{raw|processed}/dt=.../ecs_marker.json
```

Ordem sugerida no DAG (U4): Lambda → Glue → ECS (Athena/SNS depois).

## Error Semantics
- Fail-fast: falha de PutObject / JobRun / RunTask propaga ao caller.
- Sem retry policy no provisionamento TF.
- Jobs/scripts desenhados para **re-run** PoC (mesmo `dt` ou novo `dt` via parâmetro).

## Outputs for Downstream (U4)

| Output | Use |
|---|---|
| `lambda_function_arn` / `name` | Airflow LambdaInvoke |
| `glue_job_name` | Airflow GlueJobOperator |
| `ecs_cluster_arn` / `task_definition_arn` | Airflow EcsRunTaskOperator |
| `lambda_role_arn`, `glue_role_arn`, `ecs_task_role_arn`, `ecs_execution_role_arn` | docs / PassRole audit |
| `ecs_security_group_id` | network troubleshooting |
