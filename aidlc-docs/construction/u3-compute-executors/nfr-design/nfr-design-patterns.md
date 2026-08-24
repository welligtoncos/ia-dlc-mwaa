# U3 Compute Executors — NFR Design Patterns

## Resilience
| Pattern | Application in U3 |
|---|---|
| Fail-fast provision | `terraform apply` aborta em erro; sem compensação automática |
| Fail-fast runtime | Lambda/Glue/ECS propagam erro ao caller (MWAA/U4 ou smoke) |
| Smoke retry/backoff | `scripts/smoke-compute.sh` reexecuta só falhas transitórias de API |
| No DLQ / no aggressive service retries | Sem SQS DLQ Lambda; sem job bookmark obrigatório; sem ECS redeploy auto |

## Scalability
| Pattern | Application in U3 |
|---|---|
| Scale-by-config | Vars: `lambda_memory_mb`, `glue_worker_type`, `glue_number_of_workers`, `ecs_cpu`, `ecs_memory` |
| PoC defaults | Lambda 128–256 MB; Glue G.1X × 2; Fargate 256 CPU / 512 MB |
| Documented headroom | Upgrade path documentado; sem autoscaling / provisioned concurrency |

## Performance
| Pattern | Application in U3 |
|---|---|
| No cache/queue | Sem Redis/SQS entre executors |
| Explicit timeouts | Lambda timeout **60s**; Glue/ECS timeouts alinhados ao PoC |
| Minimal workers | Glue/Fargate no sizing mínimo NFR |
| Lake partition reuse | Markers e Parquet sob `dt=` herdado do layout Hive U2 |

## Security
| Pattern | Application in U3 |
|---|---|
| Defense in depth | Roles dedicadas; ARNs escopados; sem secrets no código |
| Network placement | ECS private subnets + SG egress-only; Lambda **fora** VPC |
| Constrained PassRole | MWAA PassRole só para roles Glue/ECS U3 |
| No interface VPC endpoints in U3 | Tráfego ECS→AWS APIs via NAT U1 (custo PoC consciente) |

## Mapping to NFR IDs
| Pattern area | NFR IDs |
|---|---|
| Resilience | NFR-R-01, NFR-R-04, NFR-M-04 |
| Scalability | NFR-S-01, NFR-S-02 |
| Performance | NFR-P-* |
| Security | NFR-SEC-* |
| Ops tooling | NFR-M-*, NFR-U-* |
