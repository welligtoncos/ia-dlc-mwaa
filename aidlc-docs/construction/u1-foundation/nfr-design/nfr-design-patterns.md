# U1 Foundation — NFR Design Patterns

## Resilience
| Pattern | Application in U1 |
|---|---|
| Fail-fast provision | `terraform apply` aborta em erro; sem compensação automática |
| Manual recovery | Runbook: `terraform destroy` full / parcial |
| CLI retry with backoff | `scripts/apply.sh` e `scripts/sync-dags.sh` reexecutam falhas transitórias de rede/API com backoff simples |
| No app circuit breaker | N/A (IaC + managed MWAA; sem app runtime próprio em U1) |

## Scalability
| Pattern | Application in U1 |
|---|---|
| Scale-by-config | Var `environment_class` (default `mw1.small`); documentar upgrade para `mw1.medium` |
| Documented HA toggle | Flag/doc `enable_second_nat` **não provisiona** 2º NAT; apenas descreve o caminho futuro |
| Single-AZ NAT cost tradeoff | 1 NAT explícito como CostGuardrail |

## Performance
| Pattern | Application in U1 |
|---|---|
| Lean dependency graph | Ordem Network → Artifact → Identity → MWAA; evitar recursos ornamentais |
| Accept managed lead time | Sem otimização artificial do create MWAA |
| S3 via VPC endpoint | Gateway endpoint S3 reduz path NAT para tráfego S3 (artefatos) |

## Security
| Pattern | Application in U1 |
|---|---|
| Defense in depth | BPA + SSE-S3 + least-privilege IAM + no public ACLs |
| Private data plane to S3 | VPC Gateway Endpoint for `com.amazonaws.us-east-1.s3` |
| Secrets exclusion | Nenhum secret no git; credenciais via AWS CLI profile/env |
| Conscious public UI | `PUBLIC` webserver + README threat note |
| Policy-as-code review | Apply policy U1–U4 + checklist IAM pré-apply |

## Mapping to NFR IDs
| Pattern area | NFR IDs |
|---|---|
| Resilience | NFR-R-01, BR-ERR-* |
| Scalability | NFR-S-01, NFR-S-02 |
| Performance | NFR-P-* |
| Security | NFR-SEC-01..06 + S3 endpoint (design add) |
| Ops tooling | NFR-M-*, NFR-U-* |
