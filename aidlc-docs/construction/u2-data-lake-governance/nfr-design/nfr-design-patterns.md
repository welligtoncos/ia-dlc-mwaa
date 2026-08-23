# U2 Data Lake and Governance — NFR Design Patterns

## Resilience
| Pattern | Application in U2 |
|---|---|
| Fail-fast provision | `terraform apply` aborta em erro (LF admin ausente, IAM, etc.); sem compensação automática |
| Operational error docs | Falhas de crawler vazio / grants LF pós-seed tratadas no README (não via retry no TF) |
| Seed upload retry | `scripts/seed-sample.sh` reexecuta falhas transitórias de `aws s3 cp` com backoff simples |
| No StartCrawler/LF CLI wrapper | Sem orquestração pós-apply de crawler/grants nesta unidade |

## Scalability
| Pattern | Application in U2 |
|---|---|
| Scale-by-config | Vars para `glue_database_name`, nomes de crawlers, prefixos S3 |
| Documented schedule headroom | Descrever caminho futuro `schedule` em crawlers **sem** criar o atributo agora |
| Dual crawler capacity | raw + processed on-demand cobrem lab; mais crawlers = mudança futura documentada |

## Performance
| Pattern | Application in U2 |
|---|---|
| No cache/queue | Sem Redis/SQS para lake/catalog |
| Cost-bounded results | Lifecycle **7 dias** no Athena results bucket |
| On-demand discovery | Crawlers só quando operador/DAG (U4) dispara |
| Enforce workgroup | Athena workgroup `dev` com `enforce_workgroup_configuration` |
| Hive-style path layout | Prefixos lógicos além de `raw/` e `processed/`: convenção `.../dt=YYYY-MM-DD/` (ou `year=/month=/day=`) pré-desenhada para sample e docs; crawlers apontam às raízes `raw/` e `processed/` (descobrem partições) |

## Security
| Pattern | Application in U2 |
|---|---|
| Defense in depth | BPA + SSE-S3 (data + results) + LF-Tags + least-privilege grants |
| TLS only to S3 | Bucket policies deny `aws:SecureTransport=false` em **ambos** os buckets |
| Governance tags | `Classification` ∈ {raw, processed}; `Project` = `ia-dlc-mwaa` |
| Principal grants | Crawler role, Athena/query principals, MWAA execution role (prepare U4) |
| Safe sample | CSV de exemplo sem PII/secrets |

## Mapping to NFR IDs
| Pattern area | NFR IDs |
|---|---|
| Resilience | NFR-A-*, NFR-R-*, NFR-M-03 |
| Scalability | NFR-S-01, NFR-S-02 |
| Performance | NFR-P-*, NFR-M-04 + Hive path design (Q3=B) |
| Security | NFR-SEC-* + SecureTransport deny (design add) |
| Ops tooling | NFR-M-02, NFR-U-* |
