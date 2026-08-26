# U4-orchestration-notify — NFR Design Patterns

## Resilience
| Pattern | Application |
|---|---|
| Limited retries | Tasks AWS: `retries=1`, `retry_delay=60s` |
| Execution timeouts | Lambda **5m**; Glue **45m**; ECS **30m**; Athena **15m**; SNS **2m** |
| Fail-forward notify | `on_failure_callback` → SNS failed; sem auto-heal da run |
| Manual recovery | Re-trigger DAG; start EC2 se stopped (RTO = start time) |

## Scalability
| Pattern | Application |
|---|---|
| Single active run | DAG `max_active_runs=1` (evita sobreposição acidental) |
| Lab capacity | 1 run manual / sessão; LocalExecutor (sem fila extra) |

## Performance / Runtime deps
| Pattern | Application |
|---|---|
| Provider via bootstrap | Bootstrap EC2: `pip install -r requirements.txt` no volume compartilhado **antes** do `compose up` (ou passo explícito documentado no restart) |
| Artifact requirements | `requirements.txt` na raiz do repo; sync/upload path alinhado ao pacote Compose / ArtifactStore conforme Infra Design |
| Accept slow E2E | Sem SLO; duração em minutos é esperada |

## Security
| Pattern | Application |
|---|---|
| Dual-control SNS publish | (1) Identity policy EC2 role: `sns:Publish` no ARN do tópico; (2) Topic policy: Allow Publish **somente** desse role ARN |
| Scoped Athena/Glue reads | Athena mínimo + `GetWorkGroup` / `glue:GetTable` se operators exigirem |
| No secrets in DAG | ResourceBindings só via Airflow Variables |
| No KMS CMK SNS | Default AWS-managed encryption |

## Observability
| Pattern | Application |
|---|---|
| PipelineNotifyChannel | SNS topic = canal sucesso (task final) + falha (callback) |
| Keep U1 HealthMonitor separate | Status-check alarm **não** wired ao SNS U4 |
| Operator detail | UI Airflow + logs U3 executors |

## Operator integration
| Pattern | Application |
|---|---|
| Emit-only Variables helper | `set-airflow-variables` imprime `airflow variables set ...` a partir de `terraform output`; operador cola via **SSM** na EC2 |
| E2E guide | lab-guide: start → sync → set vars → trigger → verify SNS → stop |

## Mapping to NFR IDs
| Pattern area | NFR IDs |
|---|---|
| Resilience | NFR-R-01, NFR-R-02, NFR-R-03 |
| Scalability | NFR-S-01, NFR-S-02 |
| Performance / install | NFR-M-04, FR-U4-05 |
| Security | NFR-SEC-01..06 |
| Observability | NFR-O-01..03 |
| Cost | NFR-C-01, NFR-C-02 |
| Usability | NFR-M-01, NFR-M-02 |

## Decisions locked (from NFR Design Q&A)
| Q | Decision |
|---|---|
| 1 | retries=1 + timeouts por tipo |
| 2 | `max_active_runs=1` |
| 3 | bootstrap `pip install -r requirements.txt` |
| 4 | dual-control SNS |
| 5 | SNS only; no custom CW metrics |
| 6 | sete componentes lógicos |
| 7 | script emite commands para SSM |
