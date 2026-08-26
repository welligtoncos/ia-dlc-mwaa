# U1-orchestrator-ec2 — NFR Design Patterns

## Resilience
| Pattern | Application |
|---|---|
| Bootstrap retries | user_data: retries limitados no pull S3 + `docker compose up` |
| Docker pre-pull | Retry separado para `docker pull` (digest pinado) antes do compose up |
| Container restart | systemd unit com `Restart=on-failure` para stack Compose |
| Fail-fast after N | Após esgotar retries → unit failed; sem auto-recreate EC2 no TF |
| Manual recovery | SSM Session Manager + re-run bootstrap script ou `terraform taint`/replace |

## Scalability
| Pattern | Application |
|---|---|
| Scale-by-config | Var `airflow_instance_type` default `t3.medium` |
| Documented headroom | README: upgrade `t3.large`; CeleryExecutor + workers (future) |
| Single instance | Sem ASG; lab conscious SPOF |

## Performance
| Pattern | Application |
|---|---|
| Lean TF graph | EC2 + SG + IAM + alarm + SSM param + S3 objects (compose package) |
| Pre-pull images | Reduz falha no primeiro `compose up`; retries isolados |
| Accept sync interval | DagSyncAgent 5 min — sem fila/cache |
| S3 via gateway endpoint | Pull compose + sync DAGs sem hairpin NAT quando rota usa endpoint |

## Security
| Pattern | Application |
|---|---|
| Defense in depth | IMDSv2 required + SG CIDR :8080 + SSM-only admin + least-privilege role |
| Secrets handling | UI password → SSM SecureString; zero secrets in git |
| SSE-S3 | Artifact bucket encryption (U1) |
| No SSH | SG sem 22; Session Manager only |
| Conscious public UI | IP público + CIDR + README threat note |

## Observability
| Pattern | Application |
|---|---|
| journald logging | Docker logs → journald; operator: SSM + `journalctl` |
| HealthMonitor | CloudWatch alarm EC2 status check failed |
| No SNS (U1 delta) | Alarm without SNS action until U4 |

## Mapping to NFR IDs
| Pattern area | NFR IDs |
|---|---|
| Resilience | NFR-R-01, NFR-R-02, BR-HOST-06 |
| Scalability | NFR-S-01, NFR-S-02 |
| Performance | NFR-P-01, NFR-P-02 |
| Security | NFR-SEC-01..08 |
| Cost | NFR-C-* |
| Observability | NFR-R-03, NFR-R-04 |
