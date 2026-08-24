# U3 Compute Executors — NFR Requirements

## Context
PoC `dev` / `us-east-1`. Unidade de compute: Lambda (marker raw), Glue Job (raw→processed), ECS Fargate (marker). Herda least privilege e padrões IaC de U1/U2.

## Scalability
| ID | Requirement |
|---|---|
| NFR-S-01 | Capacidade alvo: Lambda **128–256 MB**; Glue **G.1X / 2 workers**; Fargate **0.25 vCPU / 0.5 GB**. |
| NFR-S-02 | Documentar headroom (mais memória Lambda, workers Glue, CPU/mem Fargate) **sem** provisionar agora. |

## Performance
| ID | Requirement |
|---|---|
| NFR-P-01 | Sem SLO formal de latência/throughput. |
| NFR-P-02 | Aceitar cold start Lambda e startup típico Glue/ECS em lab. |

## Availability
| ID | Requirement |
|---|---|
| NFR-A-01 | Disponibilidade **best-effort** PoC. |
| NFR-A-02 | Sem multi-AZ explícito além do comportamento nativo dos serviços gerenciados. |
| NFR-A-03 | Sem RTO/RPO formais. |

## Security
| ID | Requirement |
|---|---|
| NFR-SEC-01 | Uma role por executor; least privilege; sem `Action="*"` amplo. |
| NFR-SEC-02 | Acesso S3 limitado aos paths lake necessários (raw/processed) + artifact script. |
| NFR-SEC-03 | Sem secrets no repositório; logs sem PII. |
| NFR-SEC-04 | Lambda **fora da VPC**; ECS Fargate nas subnets privadas U1 (FD). |
| NFR-SEC-05 | MWAA: Invoke/StartJobRun/RunTask + PassRole escopado apenas. |

## Reliability / Observability
| ID | Requirement |
|---|---|
| NFR-R-01 | Critério operacional: invoke Lambda OK; Glue SUCCEEDED; ECS STOPPED exit 0 + markers no lake. |
| NFR-R-02 | Logs: CloudWatch (Lambda/ECS) + logs nativos Glue. |
| NFR-R-03 | **Sem** alarmes CloudWatch→SNS nesta unidade (SNS = U4). |
| NFR-R-04 | Fail-fast; sem retry policies no Terraform. |

## Maintainability
| ID | Requirement |
|---|---|
| NFR-M-01 | Modules: `lambda_executor`, `glue_job`, `ecs_executor` + wiring root. |
| NFR-M-02 | Código em `src/` (ou `compute/`) versionado no repo. |
| NFR-M-03 | README U3: invoke manual, PassRole, dependências U1/U2. |
| NFR-M-04 | Script `scripts/smoke-compute.sh` (Lambda + Glue + ECS). |
| NFR-M-05 | `terraform fmt` + `terraform validate`. |

## Usability (operator)
| ID | Requirement |
|---|---|
| NFR-U-01 | Outputs: ARNs/names de function, job, cluster, task definition, roles. |
| NFR-U-02 | Exemplos AWS CLI no README para teste antes da U4. |

## Traceability
| Decision source | NFR IDs |
|---|---|
| Plan Q1=A | NFR-S-01, NFR-S-02 |
| Plan Q2=A | NFR-P-* |
| Plan Q3=A | NFR-A-* |
| Plan Q4=A | NFR-SEC-* |
| Plan Q5=A | (ver tech-stack-decisions.md) |
| Plan Q6=A | NFR-R-* |
| Plan Q7=B | NFR-M-* |
| Plan Q8=A | NFR-U-* |
