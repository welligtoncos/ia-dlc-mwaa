# U2 Data Lake and Governance — Tech Stack Decisions

## Selected Stack

| Layer | Choice | Rationale |
|---|---|---|
| IaC | **Terraform** `>= 1.5.0` + provider **hashicorp/aws** `~> 5.0` | Herda U1 |
| Data storage | **Amazon S3** — 2 buckets (data lake + Athena results) | Functional design U2 |
| Encryption | **SSE-S3** + BPA total em ambos | NFR-SEC-02/03; alinhado U1 |
| Cost control | S3 Lifecycle **7 dias** no bucket Athena results | NFR-M-04 |
| Catalog | **AWS Glue** Data Catalog + **2 Crawlers** (on-demand) | FR lake / U2 FD |
| Governance | **AWS Lake Formation** (LF-Tags + grants) | Classification + Project tags |
| Query | **Amazon Athena** workgroup `dev` → results bucket | U2 FD |
| Modules | `terraform/modules/{data_lake,glue_catalog,lake_formation,athena}` | Plan Q6=A |
| Operator tooling | AWS CLI v2 + `scripts/seed-sample.sh` | Plan Q7=B |
| Observability | Glue Crawler native logs/metrics | Sem SNS em U2 |

## Explicit Non-Choices (U2)

| Option | Status | Why not now |
|---|---|---|
| SSE-KMS CMK nos buckets lake | Deferred | SSE-S3 suficiente para PoC |
| Crawler schedules / mais crawlers | Document only | Headroom NFR-S-02 |
| Health-check script pós-apply LF | Deferred | Best-effort + README prereq |
| CloudWatch Alarms → SNS | U4 | Plan Q5=A |
| Sample data via Terraform | Out of scope | Seed via script; FD decision |
| Flat TF sem modules U2 | Rejected | Consistência com U1 |

## Module Responsibilities (preview for NFR Design / Infra)

| Module | Owns |
|---|---|
| `data_lake` | Data bucket + Athena results bucket, BPA, SSE-S3, lifecycle results |
| `glue_catalog` | Databases + crawlers (targets/paths) |
| `lake_formation` | LF-Tags, resource registration, grants (MWAA exec role prepared) |
| `athena` | Workgroup + result configuration |

## Compliance with Prior Decisions
- Region `us-east-1`, env `dev`, naming `{project}-{env}-`
- LF admin manual prerequisite (documented)
- Extensions Security/Resiliency/PBT: disabled (NFRs manuais acima ainda valem)
- MWAA execution role lake grants prepared in U2 (wiring com outputs U1)
