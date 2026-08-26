# U1-orchestrator-ec2 — Tech Stack Decisions

## Selected Stack

| Layer | Choice | Rationale |
|---|---|---|
| IaC | **Terraform** `>= 1.5.0` | Consistente com U1–U3 |
| Cloud plugin | **hashicorp/aws** `~> 5.0` | EC2, IAM, SSM, CW, S3 |
| State | **Local** | PoC (decisão original) |
| Orchestrator host | **EC2** `t3.medium` | Custo vs MWAA; Free Tier |
| OS | **Amazon Linux 2023** | user_data + dnf |
| Container runtime | **Docker** + **Compose v2** (pacote oficial) | Stack Airflow oficial |
| Airflow | **`apache/airflow:2.11.2`** com **digest pinado** | Reprodutibilidade (Q5=B) |
| DB (metadata) | **Postgres 13+** (container Compose) | Sem RDS; lab barato |
| Executor | **LocalExecutor** | Single-node lab |
| CLI on host | **AWS CLI v2** | s3 sync DAGs, SSM |
| Admin access | **SSM Session Manager** | Sem SSH key |
| UI password | **SSM Parameter Store** SecureString | Q4 functional design |
| Encryption | **SSE-S3** artifact bucket | Herdado U1 |
| Instance metadata | **IMDSv2 required** | NFR-SEC-06 |
| Observability | **CloudWatch** status-check alarm | Sem SNS até U4 |
| Operator scripts | **Bash** | Git Bash / WSL |

## Explicit Non-Choices

| Option | Status | Why not now |
|---|---|---|
| Amazon MWAA | Optional (`orchestrator_mode=mwaa`) | Free Tier subscription block |
| ECS Fargate local-runner | Rejected | Custo/complexidade ~ MWAA |
| RDS/Aurora Postgres | Rejected | Lab cost |
| Elastic IP | Rejected | IP dinâmico aceito (Q5 app design) |
| CeleryExecutor + workers | Document only | NFR-S-02 headroom |
| CloudWatch → SNS | U4 | Q6=B |
| SSE-KMS CMK | Deferred | SSE-S3 sufficient |

## Compose Package Layout (ArtifactStore)

```
s3://{artifact-bucket}/airflow-ec2/
  docker-compose.yml
  .env.template
  bootstrap.sh
  (optional) requirements reference
```

Upload via Terraform `aws_s3_object` on apply; EC2 user_data pulls and runs.

## Version Pins

```hcl
# versions.tf (unchanged baseline)
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

```yaml
# docker-compose.yml (conceptual — Infrastructure Design)
services:
  postgres:
    image: postgres:13
  airflow-webserver:
    image: apache/airflow:2.11.2@sha256:<pinned-digest>
  airflow-scheduler:
    image: apache/airflow:2.11.2@sha256:<pinned-digest>
```

Digest value fixed at code generation time from registry or documented pin file.

## Operator Tooling

| Tool | Use |
|---|---|
| `terraform` | apply module `airflow_ec2` |
| `aws ssm start-session` | shell na EC2 |
| `scripts/sync-dags.sh` | push DAGs → S3 |
| `scripts/airflow-ec2-start.sh` | start instance |
| `scripts/airflow-ec2-stop.sh` | stop instance |
| `scripts/airflow-ec2-status.sh` | SSM + HTTP check UI |

## Headroom (document only)

| Upgrade | When |
|---|---|
| t3.large | DAGs/heavy tasks slow scheduler |
| CeleryExecutor + Redis/Rabbit | parallel tasks beyond LocalExecutor |
| MWAA managed | account upgrade + `orchestrator_mode=mwaa` |

## Compliance
- Region `us-east-1`, env `dev`, naming `{project}-{env}-`
- Tag `CostCenter=lab` on EC2-related resources
- Extensions disabled
