# U1 Foundation — Tech Stack Decisions

## Selected Stack

| Layer | Choice | Rationale |
|---|---|---|
| IaC | **Terraform** `>= 1.5.0` | Padrão do projeto; módulos alinhados a unidades |
| Cloud provider plugin | **hashicorp/aws** `~> 5.0` | API estável para MWAA/VPC/S3/IAM |
| State | **Local** (`terraform.tfstate` no workspace) | Decisão PoC (Q3 inception); documentar risco |
| CLI ops | **AWS CLI v2** | Sync de DAGs, sts identity, troubleshooting |
| Runtime target | **Amazon MWAA** `mw1.small` | FR-01 |
| Language (helpers) | **Bash** scripts (`scripts/*.sh`) | Portável no Git Bash/WSL do operador |
| Encryption | **SSE-S3** no ArtifactBucket (default) | NFR-SEC-03; simples para PoC |
| Observability | **CloudWatch Logs** (MWAA native) | Sem SNS alarms em U1 |

## Explicit Non-Choices (U1)

| Option | Status | Why not now |
|---|---|---|
| Terraform Cloud / remote state S3+DDB | Deferred | State local já decidido |
| SSE-KMS CMK | Optional later | SSE-S3 suficiente; KMS adiciona IAM/custo |
| 2× NAT / mw1.medium | Document only | Headroom NFR-S-02 |
| CloudWatch Alarms → SNS | U4 / later | Q6=A |
| CDK / Pulumi | Out of scope | Pedido Terraform |

## Version Pins (to enforce in `versions.tf`)

```hcl
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

## Operator Tooling

| Tool | Use |
|---|---|
| `terraform` | init/plan/apply/destroy/fmt/validate |
| `aws` | credentials check, s3 sync |
| `scripts/apply.sh` | wrapper opinativo de apply |
| `scripts/sync-dags.sh` | sync `dags/` → artifact bucket (U4 content; script desde U1) |

## Compliance with Prior Decisions
- Region `us-east-1`, env `dev`, naming `{project}-{env}-`
- Extensions Security/Resiliency/PBT: disabled (não bloqueiam; NFRs manuais acima ainda valem)
