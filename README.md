# ia-dlc-mwaa

Plataforma de dados na AWS provisionada com Terraform: orquestração Airflow, data lake com governança Lake Formation, executors serverless/containers e pipeline E2E com notificação SNS.

Desenvolvido com o workflow [AI-DLC](aidlc-docs/) (Inception → Construction). Uso típico: laboratório de estudos e demonstração de arquitetura — não é um produto de produção.

---

## Arquitetura

```text
                    ┌─────────────────────────────────────────┐
                    │         VPC (10.10.0.0/16)              │
                    │                                         │
  Operator ────────►│  EC2 Airflow 2.11.2 (:8080)             │
  (CIDR /32)        │  Docker Compose · LocalExecutor         │
                    │         │                               │
                    │         ▼                               │
                    │  Lambda · Glue Job · ECS Fargate        │
                    │         │                               │
                    │         ▼                               │
                    │  S3 Data Lake · Glue Catalog · Athena   │
                    │  Lake Formation (LF-Tags + grants)      │
                    │         │                               │
                    │         ▼                               │
                    │  SNS (status do pipeline)               │
                    └─────────────────────────────────────────┘
                                      │
                                      ▼
                              S3 Artifact Bucket
                           (DAGs · Compose · requirements)
```

| Camada | Componentes |
|---|---|
| **Orquestração (U1)** | EC2 + Docker Compose (Airflow **2.11.2**) — padrão; MWAA opcional |
| **Data lake (U2)** | S3 raw/processed, Glue Catalog/Crawlers, Lake Formation, Athena |
| **Compute (U3)** | Lambda marker, Glue Job, ECS Fargate |
| **E2E + notify (U4)** | DAG `lab_pipeline_e2e`, SNS, Airflow Variables |

**Pipeline E2E (referência):** Lambda → Glue ∥ ECS → Athena → SNS.

---

## O que você pode construir

Sim — com esta stack dá para criar **pipelines batch de dados**, orquestrados no Airflow e executados nos blocos AWS abaixo.

### Blocos disponíveis

| Bloco | Uso em pipeline |
|---|---|
| **Airflow (EC2)** | Agendar, encadear tasks, retries, Variables, branches |
| **S3 data lake** | Landing / raw / processed |
| **Glue Catalog + Crawlers** | Descobrir schema e registrar tabelas |
| **Athena** | SQL sobre o lake |
| **Lake Formation** | Controle de acesso por LF-Tags (lab) |
| **Lambda** | Jobs leves / triggers / markers |
| **Glue Job** | ETL Spark (batch) |
| **ECS Fargate** | Containers (scripts, transformações, tools) |
| **SNS** | Alertas de sucesso / falha |

### Possibilidades práticas

1. **Ingestão batch** — arquivo → S3 raw → Crawler → Athena/Glue Job → processed → SNS  
2. **ETL orquestrado** — Lambda (kickoff) → Glue Job ∥ ECS → Athena (validação) → SNS *(padrão do `lab_pipeline_e2e`)*  
3. **Pipelines só SQL** — seed/crawler → Athena (`CTAS` / queries de qualidade) → SNS  
4. **Jobs containerizados** — ECS Fargate para Python, validações, exports  
5. **Microtarefas serverless** — Lambda para validar arquivo, marcar evento, chamar API, limpar paths  
6. **Multi-step com branch** — Airflow escolhe caminho (ex.: há dados → SELECT; senão → skip)  
7. **Agendamento** — cron via `schedule` do DAG ou Variable `lab_e2e_schedule`

### Como criar um pipeline novo

1. Escreva o DAG em `dags/*.py` (operators Amazon + Python/boto3)  
2. `.\scripts\sync-dags.ps1`  
3. Configure Airflow Variables (Lambda / Glue / ECS / SNS / buckets)  
4. UI → unpause + Trigger  
5. Monitore logs Airflow + mensagem SNS  

### Limites deste laboratório

- Sem streaming (Kinesis / MSK / Flink)  
- MWAA gerenciado desligado por padrão (`orchestrator_mode=ec2`)  
- Sem CI/CD de DAG, vault de secrets ou HA do Airflow  
- Escopo IAM limitado à instance role e policies U2/U3 já anexadas  

Em resumo: pipelines **batch** (ingest → transform → query → notify) com liberdade para recombinar Lambda, Glue, ECS e Athena — o DAG E2E é o template.

---

## Pré-requisitos

| Item | Observação |
|---|---|
| Terraform ≥ 1.5 | No `PATH` do PowerShell (Windows) |
| AWS CLI v2 | Conta autenticada (`aws sts get-caller-identity`) |
| IAM | Permissões alinhadas a `policies/terraform-apply-policy.json` |
| Lake Formation | Seu usuário/role como Data Lake administrator (U2) |
| Rede | `operator_cidr` = IP público `/32` para a UI Airflow |

---

## Início rápido (PowerShell)

```powershell
cd <repo-root>

# 1. Configuração
Copy-Item terraform\example.tfvars terraform\terraform.tfvars
# Edite: operator_cidr = "SEU_IP/32"

# 2. Provisionar
.\scripts\apply.ps1

# 3. Publicar DAGs e validar orquestrador
.\scripts\sync-dags.ps1
.\scripts\airflow-ec2-status.ps1   # alvo: ui_health = OK

# 4. UI — http://<public_ip>:8080  (user: admin)
aws ssm get-parameter `
  --name "$(terraform -chdir=terraform output -raw airflow_ui_password_ssm_param)" `
  --with-decryption --query Parameter.Value --output text

# 5. Encerrar a sessão (economia de custo)
.\scripts\airflow-ec2-stop.ps1
```

Retomar no dia seguinte: `.\scripts\airflow-ec2-start.ps1` → aguardar `ui_health: OK` → trabalhar → `stop`.

> Guia operacional completo: [`docs/lab-guide.md`](docs/lab-guide.md)

---

## Pipeline E2E (U4)

1. `.\scripts\apply.ps1` — SNS + IAM `sns:Publish` na role do orquestrador  
2. `.\scripts\sync-dags.ps1` — publica `dags/lab_pipeline_e2e.py` e `requirements.txt`  
3. `.\scripts\set-airflow-variables.ps1` — gera `airflow variables set ...` (aplicar via SSM no container **scheduler**)  
4. UI → unpause + **Trigger** `lab_pipeline_e2e`  
5. Verificar SNS: tópico `{prefix}pipeline-status` (subject `lab_pipeline_e2e SUCCESS`)  
6. `.\scripts\airflow-ec2-stop.ps1`

**Sucesso esperado:** tasks verdes (Lambda → Glue ∥ ECS → Athena → SNS) e mensagem SNS com `"status": "success"`.

---

## Scripts

| Ação | Windows | Linux / Git Bash |
|---|---|---|
| Terraform apply | `.\scripts\apply.ps1` | `bash scripts/apply.sh` |
| Status / health da UI | `.\scripts\airflow-ec2-status.ps1` | `bash scripts/airflow-ec2-status.sh` |
| Start / stop EC2 | `airflow-ec2-start.ps1` / `stop.ps1` | equivalentes `.sh` |
| Sync DAGs | `.\scripts\sync-dags.ps1` | `bash scripts/sync-dags.sh` |
| Airflow Variables | `.\scripts\set-airflow-variables.ps1` | `bash scripts/set-airflow-variables.sh` |
| Seed data lake | — | `bash scripts/seed-sample.sh` |
| Smoke U3 | — | `bash scripts/smoke-compute.sh` |

---

## Custo e segurança

- **Pare a EC2** quando não estiver em uso (`airflow-ec2-stop`) — principal alavanca de custo.  
- NAT Gateway permanece enquanto a stack existir (custo residual até `destroy`).  
- UI `:8080` restrita a `operator_cidr` (`/32`). Acesso ao host via **SSM** (sem SSH).  
- IP público da EC2 **muda** após stop/start — use `airflow-ec2-status.ps1`.  
- State Terraform é **local** (`terraform/terraform.tfstate`) — faça backup.  
- Free Tier: prefira `t3.small` / `t3.micro` em `terraform.tfvars`.

```powershell
cd terraform
terraform destroy -var-file=terraform.tfvars
```

---

## Estrutura do repositório

```text
├── dags/                 # DAGs Airflow (lab_pipeline_e2e)
├── docs/
│   ├── lab-guide.md      # Operação do laboratório
│   └── runbooks/         # Postmortems / recuperação
├── terraform/            # Root + modules (U1–U4)
├── scripts/              # Apply, lifecycle EC2, sync, seed, smoke
├── src/                  # Código Lambda / Glue
├── samples/              # Dados de exemplo
├── policies/             # IAM de referência para apply
└── aidlc-docs/           # Artefatos AI-DLC (requisitos, design, planos)
```

---

## Documentação

| Documento | Conteúdo |
|---|---|
| [`docs/lab-guide.md`](docs/lab-guide.md) | Provisionar, rotina diária, U2–U4, troubleshooting |
| [`docs/runbooks/airflow-ec2-bootstrap-postmortem.md`](docs/runbooks/airflow-ec2-bootstrap-postmortem.md) | CRLF, volumes, pip, região, IMDS hop limit |
| [`aidlc-docs/`](aidlc-docs/) | Estado do workflow, requisitos e designs por unidade |

---

## Licença e escopo

Projeto educacional / demonstração de arquitetura AWS + Terraform + Airflow.  
Ajuste sizing, CIDR, tags e políticas antes de qualquer uso além de laboratório.
