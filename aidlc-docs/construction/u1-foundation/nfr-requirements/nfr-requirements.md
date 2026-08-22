# U1 Foundation — NFR Requirements

## Context
PoC `dev` / `us-east-1`. Unidade de fundação MWAA (rede, artifact bucket, IAM base, ambiente).

## Scalability
| ID | Requirement |
|---|---|
| NFR-S-01 | Capacidade alvo atual: `mw1.small` + **1 NAT** (lab). |
| NFR-S-02 | Documentar headroom futuro: upgrade path para `mw1.medium` e **2 NAT** (1/AZ) **sem implementar** nesta entrega. |

## Performance
| ID | Requirement |
|---|---|
| NFR-P-01 | Sem SLO formal de latência/throughput. |
| NFR-P-02 | Aceitar duração típica de create MWAA (frequentemente 20–40+ min) e apply frio. |

## Availability
| ID | Requirement |
|---|---|
| NFR-A-01 | Disponibilidade **best-effort** PoC. |
| NFR-A-02 | Single NAT tratado como **SPOF consciente** (documentado no README). |
| NFR-A-03 | Sem RTO/RPO formais. |

## Security
| ID | Requirement |
|---|---|
| NFR-SEC-01 | Least privilege: sem `Action="*"` / `AdministratorAccess`. |
| NFR-SEC-02 | Artifact bucket: Block Public Access total. |
| NFR-SEC-03 | Artifact bucket: **encryption at rest** obrigatória (**SSE-S3** default; SSE-KMS opcional via var se necessário depois). |
| NFR-SEC-04 | Sem secrets no repositório. |
| NFR-SEC-05 | UI MWAA `PUBLIC` permitida com **aviso explícito de risco** no README. |
| NFR-SEC-06 | Policy de `terraform apply` cobre U1–U4; checklist de review IAM **obrigatório** antes do apply. |

## Reliability / Observability
| ID | Requirement |
|---|---|
| NFR-R-01 | Critério de saúde: status MWAA `AVAILABLE`. |
| NFR-R-02 | CloudWatch Logs nativos do MWAA habilitados. |
| NFR-R-03 | **Sem** alarmes CloudWatch→SNS nesta unidade (U1). |

## Maintainability
| ID | Requirement |
|---|---|
| NFR-M-01 | Código em módulos Terraform + comentários nos blocos críticos. |
| NFR-M-02 | README: init / plan / apply / destroy + pré-requisitos. |
| NFR-M-03 | Build: `terraform fmt` + `terraform validate` (+ plan quando credenciais ok). |
| NFR-M-04 | Checklist IAM review antes do apply (doc). |

## Usability (operator)
| ID | Requirement |
|---|---|
| NFR-U-01 | Variáveis com defaults sensatos e descriptions. |
| NFR-U-02 | Scripts helper: `scripts/apply.sh` e `scripts/sync-dags.sh` (sync útil desde U1 bucket; DAG completo em U4). |

## Traceability
| Decision source | NFR IDs |
|---|---|
| Plan Q1=B | NFR-S-01, NFR-S-02 |
| Plan Q2=A | NFR-P-01, NFR-P-02 |
| Plan Q3=A | NFR-A-* |
| Plan Q4=B | NFR-SEC-* (incl. SSE) |
| Plan Q5=A | (ver tech-stack-decisions.md) |
| Plan Q6=A | NFR-R-* |
| Plan Q7=B | NFR-M-* |
| Plan Q8=B | NFR-U-* |
