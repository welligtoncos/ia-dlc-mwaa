# U4-orchestration-notify — Tech Stack Decisions

## Selected Stack

| Layer | Choice | Rationale |
|---|---|---|
| IaC | **Terraform** `>= 1.5.0` + AWS provider `~> 5.0` | Consistente com U1–U3 |
| Notify | **Amazon SNS** topic + optional email subscription | FR-U4-01 / US-09 |
| Topic access | Identity policy + **SNS topic policy** (Publish → EC2 role) | NFR-SEC-04 |
| Encryption SNS | Default AWS-managed (sem CMK dedicada) | NFR-SEC-05 |
| Orchestration app | Airflow DAG `lab_pipeline_e2e` on EC2 Compose **2.11.2** | U1 host |
| AWS operators | **`apache-airflow-providers-amazon`** pin compatível com 2.11.2 | FR-U4-05 / Q5=B |
| Requirements install | Mecanismo mínimo no Compose (decidir em NFR Design: `_PIP_ADDITIONAL_REQUIREMENTS` **ou** bootstrap pip) | NFR-M-04 |
| Config bindings | **Airflow Variables** | FD BR-BIND |
| Operator helper | `scripts/set-airflow-variables.ps1` (+ `.sh`) | NFR-M-02 |
| Query | **Athena** workgroup U2 existente | FR-U4-03 |
| Executors | Lambda / Glue / ECS U3 existentes | US-06, US-07 |
| Docs | README + `docs/lab-guide.md` | FR-U4-06 |

## Explicit Non-Choices

| Option | Status | Why not now |
|---|---|---|
| Wire EC2 status-check alarm → SNS U4 | Rejected (U4) | Q7=A; alarme U1 fica separado |
| SNS KMS CMK dedicada | Rejected | Custo/complexidade lab |
| PythonOperator-only (sem amazon provider) | Rejected | Override FR-U4-05; Q5≠C |
| Soft SLO &lt; 30 min | Rejected | Q2=A |
| Parallel run concurrency guards | Rejected | Q1=A |
| Aggressive Airflow retries (2+) | Rejected | Q6=A |

## Version Pins (target)

```text
Airflow image:     apache/airflow:2.11.2 (digest already pinned in U1)
amazon provider:   apache-airflow-providers-amazon  (pin exact in Code Gen / NFR Design)
Terraform:         >= 1.5.0
hashicorp/aws:     ~> 5.0
```

## Integration Points

```text
terraform outputs (U2/U3/U4 SNS)
        |
        v
scripts/set-airflow-variables.*  -->  Airflow Variables
        |
        v
lab_pipeline_e2e DAG  -->  Lambda / Glue / ECS / Athena / SNS
```

## Decisions Locked (from NFR Q&A)

| Q | Decision |
|---|---|
| 1 | Sem meta de escala; 1 run manual/sessão |
| 2 | Sem SLO formal |
| 3 | Best-effort + RTO = start EC2 |
| 4 | Least privilege + SNS topic policy |
| 5 | Amazon provider + install path documentado |
| 6 | Retries 0–1; timeouts no NFR Design |
| 7 | SNS pipeline only; U1 alarm untouched |
| 8 | Custo mínimo + estimar no lab-guide |
| 9 | lab-guide + set-airflow-variables script |
