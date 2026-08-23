# U2 Data Lake and Governance — NFR Requirements

## Context
PoC `dev` / `us-east-1`. Unidade de lake (S3 dados + Athena results), Glue Catalog/Crawlers, Lake Formation (tags/grants) e Athena workgroup. Herda padrões de segurança e IaC da U1.

## Scalability
| ID | Requirement |
|---|---|
| NFR-S-01 | Capacidade alvo atual: **2 crawlers on-demand** (raw + curated) bastam para lab. |
| NFR-S-02 | Documentar headroom futuro: schedules diários e/ou crawlers adicionais **sem implementar** schedule nesta entrega. |

## Performance
| ID | Requirement |
|---|---|
| NFR-P-01 | Sem SLO formal de latência de crawler ou query Athena. |
| NFR-P-02 | Aceitar duração variável de crawlers e queries Athena conforme volume de sample/lab. |

## Availability
| ID | Requirement |
|---|---|
| NFR-A-01 | Disponibilidade **best-effort** PoC. |
| NFR-A-02 | Dependência explícita: **Lake Formation admin pré-configurado** na conta (manual); documentar no README. |
| NFR-A-03 | Sem RTO/RPO formais; sem health-check script pós-apply nesta unidade. |

## Security
| ID | Requirement |
|---|---|
| NFR-SEC-01 | Least privilege: grants LF e IAM de execução alinhados a papéis MWAA/Glue/Athena (sem `Action="*"`). |
| NFR-SEC-02 | Buckets de **dados** e **Athena results**: Block Public Access total. |
| NFR-SEC-03 | Ambos os buckets: encryption at rest **SSE-S3** (alinhado U1; sem CMK nesta entrega). |
| NFR-SEC-04 | Sem secrets no repositório; sample CSV sem dados sensíveis. |
| NFR-SEC-05 | Resultados Athena com lifecycle de expiração (ver NFR-M / custo abaixo). |

## Reliability / Observability
| ID | Requirement |
|---|---|
| NFR-R-01 | Critério operacional: databases/tabelas Glue visíveis após crawler bem-sucedido; workgroup Athena utilizável. |
| NFR-R-02 | Logs nativos do Glue Crawler + métricas default da AWS. |
| NFR-R-03 | **Sem** alarmes CloudWatch→SNS nesta unidade (SNS = U4). |

## Maintainability / Cost hygiene
| ID | Requirement |
|---|---|
| NFR-M-01 | Código em modules Terraform: `data_lake`, `glue_catalog`, `lake_formation`, `athena` + wiring no root. |
| NFR-M-02 | README: seção U2 (pré-req LF admin, seed sample, run crawlers, query Athena). |
| NFR-M-03 | Script `scripts/seed-sample.sh` para upload do CSV de exemplo. |
| NFR-M-04 | Lifecycle no bucket Athena results: **expirar objetos após 7 dias**. |
| NFR-M-05 | Build: `terraform fmt` + `terraform validate` (+ plan com credenciais). |

## Usability (operator)
| ID | Requirement |
|---|---|
| NFR-U-01 | Variáveis com defaults sensatos e descriptions (nomes de DB, paths crawler, workgroup). |
| NFR-U-02 | Outputs Terraform úteis: ARNs/nomes de buckets, databases, workgroup, crawlers. |

## Traceability
| Decision source | NFR IDs |
|---|---|
| Plan Q1=A | NFR-SEC-02, NFR-SEC-03 |
| Plan Q2=A | NFR-M-04, NFR-SEC-05 |
| Plan Q3=B | NFR-S-01, NFR-S-02 |
| Plan Q4=A | NFR-A-* |
| Plan Q5=A | NFR-R-* |
| Plan Q6=A | NFR-M-01 |
| Plan Q7=B | NFR-M-02, NFR-M-03, NFR-U-* |
