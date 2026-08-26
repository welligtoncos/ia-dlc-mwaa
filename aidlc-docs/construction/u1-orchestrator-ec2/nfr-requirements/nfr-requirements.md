# U1-orchestrator-ec2 — NFR Requirements

## Context
PoC `dev` / `us-east-1`. Delta U1: orquestrador **EC2 t3.medium + Docker Compose Airflow 2.11.2** (default `orchestrator_mode=ec2`). Substitui MWAA gerenciado enquanto Free Tier bloqueia assinatura.

## Scalability
| ID | Requirement |
|---|---|
| NFR-S-01 | Capacidade alvo: **1× EC2 t3.medium** + **LocalExecutor** (lab). |
| NFR-S-02 | Documentar headroom futuro: **t3.large** ou **CeleryExecutor + workers** **sem implementar** nesta entrega. |

## Performance
| ID | Requirement |
|---|---|
| NFR-P-01 | **Sem SLO formal** de latência/throughput. |
| NFR-P-02 | Aceitar boot EC2 + pull S3 + `compose up` (ordem de minutos) e sync DAGs a cada **5 min**. |

## Availability
| ID | Requirement |
|---|---|
| NFR-A-01 | Disponibilidade **best-effort** PoC. |
| NFR-A-02 | **Single EC2 = SPOF** consciente (documentado no README). |
| NFR-A-03 | **RTO soft documentado**: recriar EC2 + re-sync DAGs **< 1 h** (sem multi-AZ). |
| NFR-A-04 | Stop/start manual para controle de custo; metadata Airflow persiste em stop/start; **destroy** perde metadata. |

## Security
| ID | Requirement |
|---|---|
| NFR-SEC-01 | Least privilege: sem `Action="*"` / `AdministratorAccess` na role EC2. |
| NFR-SEC-02 | **Sem access keys** na instância; credenciais via instance profile. |
| NFR-SEC-03 | SG: ingress **8080** somente de `operator_cidr`; **sem** porta 22; egress conforme bootstrap/API AWS. |
| NFR-SEC-04 | Acesso shell = **SSM Session Manager** only. |
| NFR-SEC-05 | Senha UI Airflow gerada no bootstrap → **SSM Parameter Store** (SecureString); não commitar no repo. |
| NFR-SEC-06 | **IMDSv2 required** na EC2 (`http_tokens = required`). |
| NFR-SEC-07 | Artifact bucket: BPA + **SSE-S3** (herdado U1). |
| NFR-SEC-08 | UI exposta na internet **somente** via IP público + CIDR restrito; aviso de risco no README. |

## Reliability / Observability
| ID | Requirement |
|---|---|
| NFR-R-01 | Critério de saúde: EC2 `running` + containers Compose healthy + UI :8080 + SSM ok. |
| NFR-R-02 | Bootstrap com **retries limitados** no pull S3 + `compose up`; falha final → systemd failed (sem auto-recreate TF). |
| NFR-R-03 | **Alarme CloudWatch**: EC2 **status check failed** (sem SNS até U4). |
| NFR-R-04 | Logs: Docker → journald e/ou CloudWatch agent (detalhe em NFR Design); sem SNS alarms nesta unidade. |

## Cost
| ID | Requirement |
|---|---|
| NFR-C-01 | README: custo estimado **~US$ 1–2/dia** se EC2 24h; recomendar **stop** quando idle. |
| NFR-C-02 | Scripts `airflow-ec2-start.sh` / `airflow-ec2-stop.sh`. |
| NFR-C-03 | Tag default **`CostCenter=lab`** nos recursos EC2/SG/EIP-related (se aplicável). |
| NFR-C-04 | Sugerir **AWS Budget alert** (fora do Terraform) para créditos Free Tier. |

## Maintainability
| ID | Requirement |
|---|---|
| NFR-M-01 | Módulo `airflow_ec2` + wiring `orchestrator_mode` no root. |
| NFR-M-02 | `terraform fmt` + `terraform validate` obrigatórios. |
| NFR-M-03 | README: seção EC2 Airflow (UI, SSM, senha SSM, IP dinâmico pós stop/start). |
| NFR-M-04 | Checklist IAM review antes do apply (herdado U1). |

## Usability (operator)
| ID | Requirement |
|---|---|
| NFR-U-01 | Variáveis: `orchestrator_mode`, `operator_cidr`, paths compose no bucket. |
| NFR-U-02 | Scripts: `sync-dags.sh`, `airflow-ec2-start/stop`, **`airflow-ec2-status.sh`** (SSM + curl UI). |

## Traceability
| Decision source | NFR IDs |
|---|---|
| Plan Q1=B | NFR-S-01, NFR-S-02 |
| Plan Q2=A | NFR-P-01, NFR-P-02 |
| Plan Q3=B | NFR-A-03 |
| Plan Q4=B | NFR-SEC-05, NFR-SEC-06, NFR-SEC-07 |
| Plan Q5=B | (tech-stack-decisions.md) |
| Plan Q6=B | NFR-R-03 |
| Plan Q7=B | NFR-C-* |
| Plan Q8=B | NFR-U-02, NFR-M-03 |

## Extension Compliance
Security / Resiliency / PBT extensions **disabled** — NFRs acima são requisitos manuais do lab.
