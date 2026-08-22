# Unit of Work — Story Map

## Stories → Units

| Story | Title | Primary Unit | Secondary |
|---|---|---|---|
| US-01 | Rede mínima MWAA | **U1** | — |
| US-02 | Ambiente MWAA mw1.small PUBLIC | **U1** | — |
| US-03 | Bucket artefatos Airflow | **U1** | U4 (sync consumer) |
| US-04 | Policy mínima terraform apply | **U1** | — |
| US-05 | Publish DAG via s3 sync | **U4** | U1 ArtifactStore |
| US-06 | Task Lambda no DAG | **U3** | U4 PipelineApp |
| US-07 | Glue Job + ECS Fargate no DAG | **U3** | U2 lake/catalog, U4 |
| US-08 | Lake Formation + LF-Tags | **U2** | — |
| US-09 | Athena + SNS | **U2** (Athena) + **U4** (SNS/DAG) | — |
| US-10 | IAM least privilege transversal | **U1** + **U3** | U2 grants LF |

## Coverage Check

| Unit | Stories covered |
|---|---|
| U1 | US-01, US-02, US-03, US-04, US-10 (base) |
| U2 | US-08, US-09 (Athena), US-07 (catalog/lake support) |
| U3 | US-06, US-07, US-10 (compute policies) |
| U4 | US-05, US-09 (SNS), E2E glue of US-06/07/09 |

**Unassigned stories**: nenhuma.

## Persona → Units

| Persona | Units |
|---|---|
| P1 Platform Engineer | U1 (lead), U3 (IAM review) |
| P2 Data Engineer | U3, U4 |
| P3 Security/Governance | U2, U1/U3 (US-10 review) |

## Construction Sequencing Hint
- Sprint/loop 1: U1  
- Sprint/loop 2: U2 ∥ U3  
- Sprint/loop 3: U4 + E2E acceptance  
