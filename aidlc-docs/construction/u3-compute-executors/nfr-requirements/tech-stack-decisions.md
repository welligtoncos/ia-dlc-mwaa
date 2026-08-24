# U3 Compute Executors — Tech Stack Decisions

## Selected Stack

| Layer | Choice | Rationale |
|---|---|---|
| IaC | **Terraform** `>= 1.5.0` + **hashicorp/aws** `~> 5.0` | Herda U1/U2 |
| Serverless | **AWS Lambda** Python **3.12**, 128–256 MB, zip via `archive_file` | FD + NFR |
| ETL | **AWS Glue** Job **4.0** / Spark, worker type **G.1X**, **2** workers | PoC cost |
| Container | **Amazon ECS** on **Fargate**; image pública com AWS CLI | Sem ECR |
| Network | ECS nas private subnets U1 + SG egress; Lambda **not** in VPC | NFR-SEC-04 |
| Identity | Roles dedicadas Lambda / Glue / ECS exec+task | NFR-SEC-01 |
| Observability | CloudWatch Logs + Glue job logs | Sem SNS U3 |
| Operator | README CLI examples + `scripts/smoke-compute.sh` | Q7=B, Q8=A |
| Modules | `lambda_executor`, `glue_job`, `ecs_executor` | FD Q9 |

## Explicit Non-Choices (U3)

| Option | Status | Why not now |
|---|---|---|
| Lambda in VPC | Rejected for PoC | ENI cold start / complexity |
| Glue Python Shell | Rejected | Spark passthrough Parquet alinhado ao lake |
| ECR custom image | Deferred | Imagem pública suficiente |
| Medium sizing | Document only | Headroom NFR-S-02 |
| CW Alarms → SNS | U4 | Q6=A |
| Step Functions / EventBridge runner | Out of scope | Orquestração = U4 |
| Monolithic `compute` module | Rejected | Consistência modular |

## Module Responsibilities (preview)

| Module | Owns |
|---|---|
| `lambda_executor` | Function, role, zip package, log group |
| `glue_job` | Job, role, script object on U1 artifact bucket |
| `ecs_executor` | Cluster, task def, roles, SG; Fargate network config |
| Root | Wire U1/U2 outputs; MWAA invoke/start/run + PassRole policy |

## Compliance with Prior Decisions
- Region `us-east-1`, env `dev`, naming `{project}-{env}-`
- Data I/O only via U2 lake paths; script on U1 artifact bucket
- Extensions Security/Resiliency/PBT: disabled (NFRs manuais acima ainda valem)
