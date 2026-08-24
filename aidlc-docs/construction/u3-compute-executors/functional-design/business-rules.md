# U3 Compute Executors — Business Rules

## Identity & Privilege (US-10 compute)

| ID | Rule |
|---|---|
| BR-IAM-01 | Uma **IAM role por executor** (Lambda, Glue, ECS execution, ECS task) — sem role “compute” compartilhada. |
| BR-IAM-02 | Policies dos executors: mínimo para S3 lake paths necessários + logs + Catalog (Glue) + ECR public pull implícito via execution role. |
| BR-IAM-03 | MWAA execution role recebe **apenas** Invoke/StartJobRun/RunTask(+Describe/Stop) nos recursos U3 + `iam:PassRole` restrito aos roles ECS/Glue. |
| BR-IAM-04 | Proibido `Action="*"` / `Resource="*"` amplo nas policies de executor (exceto onde API AWS exige `*` documentado, ex. alguns logs create — preferir ARN scoped). |

## Lambda (US-06)

| ID | Rule |
|---|---|
| BR-L-01 | Lambda **deve** escrever marcador JSON em `raw/dt=<date>/lambda_marker.json` no data lake U2. |
| BR-L-02 | Falha de escrita S3 ⇒ falha da invocação (não engolir erro). |
| BR-L-03 | Código empacotado via zip local no apply; sem ECR/Lambda container neste PoC. |
| BR-L-04 | Sem dados sensíveis/PII no marcador (apenas metadata de execução). |

## Glue Job (US-07)

| ID | Rule |
|---|---|
| BR-G-01 | Job lê de `raw/` e escreve Parquet em `processed/dt=<date>/`. |
| BR-G-02 | Script armazenado no **artifact bucket U1** (não no data lake). |
| BR-G-03 | Sem schedule do Glue Job; disparo só via caller (MWAA/U4). |
| BR-G-04 | Re-run no mesmo `dt` permitido (overwrite/append PoC documentado). |

## ECS Fargate (US-07)

| ID | Rule |
|---|---|
| BR-E-01 | Task **deve** escrever marcador no lake via AWS CLI (não só echo). |
| BR-E-02 | Task roda em **subnets privadas U1**, `assign_public_ip = DISABLED`. |
| BR-E-03 | Imagem pública (sem ECR); pull depende do NAT U1. |
| BR-E-04 | SG dedicado: egress necessário para S3/API; sem ingress de negócio. |

## Orchestration boundary

| ID | Rule |
|---|---|
| BR-O-01 | U3 **não** cria DAG, Step Functions nem EventBridge runner. |
| BR-O-02 | Contratos/outputs bastam para U4 orquestrar Lambda → Glue → ECS. |
| BR-O-03 | Fail-fast; retries de workflow ficam no Airflow (U4), não no TF U3. |

## Traceability

| Plan answer | Rules |
|---|---|
| Q1=B | BR-L-01..04 |
| Q2=A | BR-G-01..04 |
| Q3=B | BR-E-01 |
| Q4=A | BR-L-03, BR-G-02, BR-E-03 |
| Q5=A | BR-IAM-* |
| Q6=A | BR-E-02, BR-E-04 |
| Q7=A | BR-O-01, BR-O-02 |
| Q8=A | BR-O-03 + fail-fast nos executors |
| Q9=A | modules `lambda_executor`, `glue_job`, `ecs_executor` (infra/code) |
