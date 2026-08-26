# Requirements — Change: Orquestrador EC2 + Docker Compose

## Intent Analysis Summary

| Field | Value |
|---|---|
| **User request** | Hospedar Airflow 2.11.2 em EC2 `t3.medium` + Docker Compose na VPC do lab, sem MWAA gerenciado (bloqueado pelo Free Tier) |
| **Request type** | Migração / substituição de componente (orquestrador) |
| **Scope estimate** | Múltiplos componentes (U1 delta + IAM U2/U3 wiring + scripts U4-adjacent) |
| **Complexity** | Moderada |
| **Requirements depth** | Padrão |
| **Region / Environment** | `us-east-1` / `dev` (inalterado) |

## Decisions Locked (from Q&A)

| Topic | Decision |
|---|---|
| Alternativa | **B** — EC2 + Docker Compose (não Fargate local-runner; MWAA real só se surgir necessidade) |
| Instance | `t3.medium` na **subnet pública** do lab |
| UI | Porta **8080** liberada no SG **somente do CIDR do operador** (variável Terraform) |
| MWAA module | `orchestrator_mode = "ec2" \| "mwaa"` com **default `ec2`** |
| DAGs | `sync-dags.sh` → bucket artefatos; na EC2 **`aws s3 sync` periódico** → volume Compose |
| Stack Docker | Apache Airflow **2.11.x** oficial, **LocalExecutor**, Postgres **no Compose** (sem RDS) |
| Custo | Scripts **start/stop** + README (terminate/destroy documentados) |
| IAM | Nova role **`airflow-ec2-execution`** (instance profile); policies lake/compute migradas/espelhadas; role MWAA só usada se `orchestrator_mode=mwaa` |
| Security / Resiliency / PBT | **Desabilitadas** |

## Relationship to Baseline Requirements

- Mantém: U2 lake/governance, U3 executors, U4 DAG E2E + SNS, rede/VPC, artifact bucket, sync fora do Terraform.
- Substitui (default): FR-01 MWAA gerenciado → EC2 + Compose.
- FR-03: subnets privadas/NAT permanecem (ECS U3); EC2 Airflow usa subnet **pública**.
- Webserver: deixa de ser `PUBLIC_ONLY` do MWAA; passa a ser UI Docker na EC2 com SG por IP.

## Functional Requirements

### FR-EC2-01 — Instância orquestradora
- Provisionar EC2 `t3.medium` (Amazon Linux 2023 ou Ubuntu LTS) na subnet pública existente.
- `user_data` (ou bootstrap idempotente): Docker + Compose plugin; clonar/configurar stack Airflow 2.11.x; iniciar Compose.
- Associar **instance profile** com role `airflow-ec2-execution`.
- Elastic IP opcional: **não obrigatório** se IP público da subnet bastar; documentar que IP muda em stop/start (operador atualiza CIDR/SG ou usa EIP se necessário). **Default: EIP** para lab estável de acesso UI/SSH — confirmar no design se custo EIP (~US$ 0 se attached) for aceito. *Locked for design default: allocate EIP for stable operator access.*

### FR-EC2-02 — Rede e acesso
- Security group dedicado: ingress **22** e **8080** apenas de `var.operator_cidr` (obrigatório); egress all (ou HTTPS/HTTP/DNS mínimos).
- Airflow UI em `:8080` via browser no IP (EIP ou público).
- Sem ALB nesta mudança.

### FR-EC2-03 — Docker Compose Airflow
- Serviços mínimos: `postgres`, `airflow-webserver`, `airflow-scheduler` (LocalExecutor; workers embutidos no scheduler conforme compose oficial LocalExecutor).
- Versão de imagem alinhada a **2.11.2** (tag pinada).
- Credenciais UI default de lab documentadas no README (trocar em lab sério).
- Volume local para `dags/` alimentado pelo sync S3.

### FR-EC2-04 — Sync de DAGs
- Manter `scripts/sync-dags.sh` → bucket de artefatos.
- Na EC2: job periódico (`cron` ou systemd timer) `aws s3 sync s3://…/dags/ → /opt/airflow/dags` (path final no design).
- Sem upload de DAGs pelo Terraform.

### FR-EC2-05 — Modo orquestrador
- Variável `orchestrator_mode` (`ec2` | `mwaa`), default **`ec2`**.
- Com `ec2`: não criar `aws_mwaa_environment`; criar módulo EC2/Compose.
- Com `mwaa`: comportamento U1 original (só se conta tiver assinatura MWAA).
- Módulo `modules/mwaa` permanece no repo.

### FR-EC2-06 — IAM
- Role nova `…-airflow-ec2-execution` com trust `ec2.amazonaws.com`.
- Policies equivalentes às necessárias para orquestrar U2/U3 (lake, Glue, Lambda, ECS, Athena, S3 artefatos) — least privilege; espelhar grants hoje na role MWAA.
- Instance profile anexado à EC2.
- Role MWAA e policies associadas só provisionadas / usadas quando `orchestrator_mode=mwaa` (ou mantidas mas sem attachment EC2).

### FR-EC2-07 — Operação de custo
- `scripts/airflow-ec2-stop.sh` e `scripts/airflow-ec2-start.sh`.
- README: stop/start, destroy/terminate, aviso de custo ~US$ 1–2/dia, Free Tier vs MWAA.

### FR-EC2-08 — Integração U3/U4
- Executors U3 continuam invocáveis pela role da EC2 (não pela role MWAA, no modo default).
- U4: DAG E2E e sync docs atualizados para EC2 (UI URL, sync, smoke).

## Non-Functional Requirements

| ID | Requirement |
|---|---|
| NFR-EC2-01 | Custo controlável: stop da instância quando idle |
| NFR-EC2-02 | Sem RDS/Aurora (Postgres só no Compose) |
| NFR-EC2-03 | Sem access keys na instância (só instance role) |
| NFR-EC2-04 | Lab/PoC: sem HA; single AZ/instance aceitável |
| NFR-EC2-05 | SG não pode ser `0.0.0.0/0` em 8080/22 |

## Out of Scope (this change)

- Upgrade de plano Free Tier / MWAA real (modo `mwaa` reservado).
- ECS Fargate local-runner.
- ALB, HTTPS cert, Multi-AZ Airflow.
- Mudança de modelo do lake U2 ou dos três executors U3 (além do principal IAM).

## Extension Compliance

| Extension | Status |
|---|---|
| Security Baseline | Disabled |
| Resiliency Baseline | Disabled |
| Property-Based Testing | Disabled |

## Key Summary

Orquestrador default passa a ser **EC2 pública + Compose Airflow 2.11.2 (LocalExecutor + Postgres local)**, com UI restrita por CIDR, DAGs via S3 sync, role dedicada `airflow-ec2-execution`, e interruptor `orchestrator_mode` para MWAA futuro.
