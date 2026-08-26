# U1-orchestrator-ec2 — Business Rules

## BR-MODE — Orchestrator mode

| ID | Rule |
|---|---|
| BR-MODE-01 | `orchestrator_mode` ∈ {`ec2`, `mwaa`}; **default `ec2`**. |
| BR-MODE-02 | Em `ec2`: **não** criar role MWAA nem `aws_mwaa_environment`. |
| BR-MODE-03 | Em `mwaa`: aplicar regras legacy U1 MWAA (conta deve ter assinatura). |

## BR-HOST — AirflowHost (EC2)

| ID | Rule |
|---|---|
| BR-HOST-01 | Instance type = `t3.medium`; AMI family = Amazon Linux 2023. |
| BR-HOST-02 | Placement = **subnet pública** existente do lab. |
| BR-HOST-03 | **Sem EIP**; IP público dinâmico aceito (documentar pós stop/start). |
| BR-HOST-04 | SG: ingress **8080** somente de `operator_cidr`; **sem** regra 22; egress permitido para boot/pull/API AWS. |
| BR-HOST-05 | Acesso administrativo = **SSM Session Manager** only (sem key pair obrigatório). |
| BR-HOST-06 | Bootstrap com **retries limitados** (ex. 3) no pull S3 + `compose up`; após esgotar → serviço failed; **sem** recreate automático TF. |

## BR-COMPOSE — ComposeStack

| ID | Rule |
|---|---|
| BR-COMPOSE-01 | Airflow imagem **2.11.2** (tag pinada). |
| BR-COMPOSE-02 | Executor = **LocalExecutor**; Postgres **no Compose** (sem RDS). |
| BR-COMPOSE-03 | Serviços mínimos: postgres, webserver, scheduler. |
| BR-COMPOSE-04 | Pacote Compose vive no ArtifactStore (`airflow-ec2/`); user_data apenas baixa e sobe. |
| BR-COMPOSE-05 | Senha UI **gerada no bootstrap** e armazenada em **SSM Parameter Store** (SecureString preferível). |

## BR-SYNC — DagSyncAgent

| ID | Rule |
|---|---|
| BR-SYNC-01 | Timer = **a cada 5 minutos**. |
| BR-SYNC-02 | Sync unidirecional S3 `dags/` → path local montado no Compose. |
| BR-SYNC-03 | Terraform **não** faz upload de DAGs de negócio; operador usa `sync-dags.sh`. |

## BR-ACCEPT — Readiness & smoke

| ID | Rule |
|---|---|
| BR-ACCEPT-01 | EC2 state `running`. |
| BR-ACCEPT-02 | Containers Compose healthy (webserver, scheduler, postgres). |
| BR-ACCEPT-03 | UI HTTP alcançável do `operator_cidr` na porta 8080. |
| BR-ACCEPT-04 | SSM `start-session` bem-sucedido. |
| BR-ACCEPT-05 | Smoke: após sync de DAG placeholder, **listar DAGs** via UI ou API Airflow. |
| BR-ACCEPT-06 | DAG E2E completo **não** é critério deste delta (U4). |

## BR-COST — Lifecycle

| ID | Rule |
|---|---|
| BR-COST-01 | Scripts `airflow-ec2-stop.sh` / `airflow-ec2-start.sh` + README. |
| BR-COST-02 | Metadata Postgres em volume Docker no root EBS: **persiste** stop/start; **perdida** no destroy da instância. |

## BR-IAM — Execution identity

| ID | Rule |
|---|---|
| BR-IAM-01 | Role `…-airflow-ec2-execution` + instance profile; sem access keys. |
| BR-IAM-02 | Incluir SSM Managed Instance Core. |
| BR-IAM-03 | Proibido `Action="*"` / `AdministratorAccess`. |
| BR-IAM-04 | Policies lake/compute anexadas ao principal EC2 no modo default (wiring U2/U3). |

## Coverage FR-EC2
FR-EC2-01..08 cobertos pelas regras acima (HOST, COMPOSE, SYNC, MODE, COST, IAM, ACCEPT).
