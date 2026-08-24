# U3 Code Generation Summary

**Unit**: U3 Compute Executors  
**Generated**: 2026-08-23  
**Status**: Code generated per approved plan

## Application artifacts (workspace root)

| Path | Purpose |
|---|---|
| `src/lambda_marker/handler.py` | Lambda marker → `raw/dt=` |
| `src/glue/glue_passthrough.py` | Glue job raw → Parquet `processed/dt=` |
| `terraform/modules/lambda_executor/` | Function + role + zip |
| `terraform/modules/glue_job/` | Job + role + script on artifact bucket |
| `terraform/modules/ecs_executor/` | Cluster + Fargate task + SG + roles |
| `terraform/main.tf` | U3 wiring + `mwaa-compute-access` policy |
| `scripts/smoke-compute.sh` | Invoke Lambda + Glue + ECS with retry |
| `README.md` | Seção U3 / CLI / PassRole |

## Docs

| Path | Purpose |
|---|---|
| Este summary | Rastreio da geração |
| `aidlc-docs/construction/shared-infrastructure.md` | Contrato U1–U3 |

## Validation

- `terraform fmt` / `terraform validate` — ver resultado da sessão

## Out of scope

- DAGs / SNS → U4  
- ECS Service / ECR / Lambda-in-VPC / DLQ / alarms  
