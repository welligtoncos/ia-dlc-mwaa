# U4-orchestration-notify — NFR Requirements

## Context
PoC `dev` / `us-east-1`. Unidade U4: DAG E2E + SNS + IAM orquestrador + requirements Amazon provider + docs/script de Variables. Security Baseline extension **disabled**; least privilege do stack permanece.

## Scalability
| ID | Requirement |
|---|---|
| NFR-S-01 | Capacidade alvo: **1 run manual** do DAG E2E por sessão de estudo. |
| NFR-S-02 | LocalExecutor na EC2 atual é suficiente; sem concurrency guards adicionais. |

## Performance
| ID | Requirement |
|---|---|
| NFR-P-01 | **Sem SLO formal** de duração da run E2E. |
| NFR-P-02 | Aceitar duração típica de lab (Lambda/Glue/ECS/Athena em minutos). |

## Availability
| ID | Requirement |
|---|---|
| NFR-A-01 | Disponibilidade **best-effort**; depende de EC2 Airflow + U2/U3. |
| NFR-A-02 | Sem HA da pipeline; falha → retry **manual**. |
| NFR-A-03 | Se EC2 **stopped**, E2E indisponível até `airflow-ec2-start`; **RTO operacional = tempo de start** (documentar no lab-guide). |

## Security
| ID | Requirement |
|---|---|
| NFR-SEC-01 | Least privilege: `sns:Publish` **somente** no tópico U4. |
| NFR-SEC-02 | Athena: ações mínimas escopadas a workgroup/output existentes (+ `GetWorkGroup` / `glue:GetTable` se operators exigirem). |
| NFR-SEC-03 | Sem secrets no código do DAG; configuração via **Airflow Variables**. |
| NFR-SEC-04 | **SNS topic policy** restringe `sns:Publish` ao role EC2 do orquestrador (além da identity policy). |
| NFR-SEC-05 | Sem KMS CMK dedicada no SNS nesta U4 (SSE default SNS/AWS managed). |
| NFR-SEC-06 | Sem `Action="*"` / AdministratorAccess nas policies U4. |

## Reliability
| ID | Requirement |
|---|---|
| NFR-R-01 | Retries Airflow nas tasks AWS: **0–1**; sem circuit breaker. |
| NFR-R-02 | Timeouts por task definidos no NFR Design (valores explícitos). |
| NFR-R-03 | Falha de task → `on_failure_callback` SNS (FD); sem auto-heal da run. |

## Observability
| ID | Requirement |
|---|---|
| NFR-O-01 | Canal principal de sucesso/falha da pipeline = **SNS do DAG**. |
| NFR-O-02 | Alarme CloudWatch EC2 status-check (U1) **permanece separado**; **não** amarrar ao SNS U4 nesta unidade. |
| NFR-O-03 | UI Airflow + logs dos executors U3 continuam fonte de detalhe. |

## Cost
| ID | Requirement |
|---|---|
| NFR-C-01 | SNS + Athena de exemplo com volume mínimo; schedule default off; e-mail subscription opcional. |
| NFR-C-02 | Documentar no lab-guide custo marginal estimado SNS/Athena (**~centavos** por sessão). |

## Maintainability / Usability
| ID | Requirement |
|---|---|
| NFR-M-01 | lab-guide: lista de Variables + mapeamento `terraform output` + sync/trigger/verify SNS. |
| NFR-M-02 | Script helper `scripts/set-airflow-variables.ps1` (e `.sh` se padrão do repo) que lê outputs TF e seta Variables via API/CLI Airflow. |
| NFR-M-03 | `terraform fmt` + `validate` após módulo SNS + IAM. |
| NFR-M-04 | Mecanismo de instalação de `requirements.txt` no Compose EC2 documentado (detalhe no NFR Design). |

## Traceability
| Decision source | NFR IDs |
|---|---|
| Plan Q1=A | NFR-S-01, NFR-S-02 |
| Plan Q2=A | NFR-P-01, NFR-P-02 |
| Plan Q3=B | NFR-A-01..03 |
| Plan Q4=B | NFR-SEC-01..05 |
| Plan Q5=B | (tech-stack + NFR-M-04) |
| Plan Q6=A | NFR-R-01, NFR-R-02 |
| Plan Q7=A | NFR-O-01, NFR-O-02 |
| Plan Q8=B | NFR-C-01, NFR-C-02 |
| Plan Q9=B | NFR-M-01, NFR-M-02 |

## Extension Compliance
| Extension | Enabled | Applicable | Status |
|---|---|---|---|
| Security Baseline | No | N/A | Ignored |
