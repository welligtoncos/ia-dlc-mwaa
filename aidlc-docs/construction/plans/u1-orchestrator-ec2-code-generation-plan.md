# U1-orchestrator-ec2 — Code Generation Plan



**Unidade**: U1-orchestrator-ec2 (delta brownfield)  

**Workspace root**: `d:\projetos-ia-aws\ia-dlc-mwaa`  

**Código**: NUNCA em `aidlc-docs/`  

**Docs**: `aidlc-docs/construction/u1-orchestrator-ec2/code/`



**FRs**: FR-EC2-01..08  

**Dependências**: U1 network/artifact existentes; U2/U3 IAM rewire  

**Consumidores**: U4 (orchestrator_role_arn, airflow_ui_url)



Este plano é a **única fonte da verdade** para a Geração de Código deste delta.



---



## Contexto



| Item | Valor |

|---|---|

| Modo default | `orchestrator_mode = "ec2"` |

| Módulos novos | `airflow_ec2`, `airflow_ec2_identity` |

| Módulos alterados | `main.tf`, `variables.tf`, `outputs.tf`, `identity` (count MWAA), lake_formation grant principal |

| Scripts novos | `airflow-ec2-start/stop/status.sh` |

| Compose | `modules/airflow_ec2/files/` → S3 `airflow-ec2/` |



---



## Etapas de geração (Part 2)



### Etapa 1 — Variáveis e locals root

- [x] `variables.tf`: `orchestrator_mode`, `operator_cidr`, `airflow_instance_type`, `airflow_image_digest` (ou tag pin)

- [x] Validação `orchestrator_mode` ∈ {ec2, mwaa}; `operator_cidr` obrigatório quando ec2



### Etapa 2 — Module `airflow_ec2_identity`

- [x] Role trust `ec2.amazonaws.com`

- [x] Instance profile

- [x] `AmazonSSMManagedInstanceCore`

- [x] Base S3 artifacts + SSM PutParameter/GetParameter no path senha UI

- [x] Outputs: `role_arn`, `role_name`, `instance_profile_name`



### Etapa 3 — Module `airflow_ec2`

- [x] Data source AL2023 AMI

- [x] SG (8080/operator_cidr, egress all)

- [x] EC2 t3.medium, 30 GiB gp3 root, IMDSv2, public subnet, instance profile

- [x] Tag `CostCenter=lab`

- [x] `aws_s3_object` upload de `files/*` para `airflow-ec2/`

- [x] SSM parameter placeholder UI password

- [x] CloudWatch alarm StatusCheckFailed

- [x] `user_data` template (bootstrap: docker, pre-pull, compose up, dag sync timer, systemd)

- [x] `files/`: docker-compose.yml (Airflow 2.11.2 digest), bootstrap.sh, systemd units



### Etapa 4 — Root wiring condicional

- [x] `module.identity` count quando mode=mwaa

- [x] `module.mwaa` count quando mode=mwaa

- [x] `module.airflow_ec2_identity` + `module.airflow_ec2` count quando mode=ec2

- [x] Local `orchestrator_role_arn` / `orchestrator_role_name`

- [x] Rewire `aws_iam_role_policy` lake + compute para role ativa

- [x] `lake_formation` grant: usar orchestrator role ARN



### Etapa 5 — Outputs root

- [x] `orchestrator_mode`, `orchestrator_role_arn`

- [x] EC2: `airflow_ec2_instance_id`, `airflow_ec2_public_ip`, `airflow_ui_url`, `airflow_ec2_role_arn`

- [x] MWAA outputs condicionais (null ou omit quando ec2)



### Etapa 6 — Scripts operador

- [x] `scripts/airflow-ec2-start.sh`

- [x] `scripts/airflow-ec2-stop.sh`

- [x] `scripts/airflow-ec2-status.sh` (SSM + curl UI)

- [x] LF line endings (`.gitattributes` já existente)



### Etapa 7 — README + docs código

- [x] README: seção EC2 Airflow, custo, IP dinâmico, senha SSM, stop/start

- [x] `aidlc-docs/construction/u1-orchestrator-ec2/code/code-generation-summary.md`



### Etapa 8 — Placeholder DAG smoke

- [x] `dags/placeholder_smoke.py` mínimo (listável na UI; E2E completo em U4)



### Etapa 9 — Validação

- [x] `terraform fmt`

- [x] `terraform validate`



---



## Fora do escopo desta geração

- U4 SNS + DAG E2E completo

- Upgrade para MWAA real (mode flag only)

- CeleryExecutor / t3.large provisionados



---



## Aprovação



Responda **Aprovar plano de código U1-orchestrator-ec2** ou **Solicitar alterações**.


