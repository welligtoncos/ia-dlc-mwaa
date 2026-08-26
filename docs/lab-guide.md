# Guia do laboratório — estudar com a plataforma

Este guia cobre o dia a dia: **provisionar**, **ligar**, **usar**, **desligar** e **destruir** a infraestrutura do lab `ia-dlc-mwaa`.

**Orquestrador default:** Airflow 2.11.2 em EC2 + Docker Compose (`orchestrator_mode=ec2`).  
**Stack:** VPC · S3 (artefatos + data lake) · Lake Formation · Glue · Athena · Lambda · Glue Job · ECS Fargate · **SNS + DAG E2E**.

---

## 1. O que você precisa no computador

| Ferramenta | Uso |
|---|---|
| **PowerShell** (Windows) ou Git Bash/WSL | Rodar scripts |
| **Terraform** ≥ 1.5 no PATH do PowerShell | IaC (`where.exe terraform`) |
| **AWS CLI v2** | Conta autenticada (`aws sts get-caller-identity`) |
| Navegador | UI Airflow `:8080` |
| Session Manager Plugin (opcional) | Shell na EC2 via SSM |

**Windows:** use os scripts `.ps1` neste guia. O `bash` do WSL muitas vezes **não vê** o Terraform instalado no Windows.

```powershell
cd D:\projetos-ia-aws\ia-dlc-mwaa
aws sts get-caller-identity
terraform version
```

---

## 2. Mapa rápido de custos (ligar / desligar)

| Recurso | Enquanto “ligado” | Como economizar |
|---|---|---|
| **EC2 Airflow** | Cobra por hora (~US$ 1–2/dia em `t3.small`/`t3.medium`) | `.\scripts\airflow-ec2-stop.ps1` ao terminar o estudo |
| **NAT Gateway** | Cobra quase sempre (enquanto existir) | Só some com `terraform destroy` |
| **S3 / Glue / Lambda / Athena** | Pay-per-use | Baixo em lab; evite Glue/ECS longos |
| **EBS 30 GiB** | Cobra mesmo com EC2 parada | Aceitável no lab |

**Regra de ouro do estudo:** ao fechar o dia → **pare a EC2**. Não precisa destruir a stack toda.

---

## 3. Primeira vez — provisionar

### 3.1 Configurar variáveis

```powershell
cd D:\projetos-ia-aws\ia-dlc-mwaa
Copy-Item terraform\example.tfvars terraform\terraform.tfvars
```

Edite `terraform\terraform.tfvars`:

```hcl
orchestrator_mode     = "ec2"
operator_cidr         = "SEU_IP_PUBLICO/32"   # obrigatório para abrir a UI
airflow_instance_type = "m7i-flex.large"   # 8 GiB — recomendado (t3.small OOM)
```

**Descobrir seu IP público** (o que a AWS enxerga):

```powershell
curl.exe -s ifconfig.me
```

Não use IP da LAN (`192.168.x.x`). Se usar VPN (ex. Topaz), use o IP do túnel.

### 3.2 Apply

```powershell
.\scripts\apply.ps1
```

Aguarde o apply. Na primeira vez pode levar vários minutos.

### 3.3 Aguardar bootstrap do Airflow

Após criar/iniciar a EC2, o `user_data` instala Docker, sobe Compose e gera a senha. Em **`t3.small`** espere **5–15 minutos**.

```powershell
.\scripts\airflow-ec2-status.ps1
```

Alvos:

| Campo | Esperado |
|---|---|
| `state` | `running` |
| `ssm_ping` | `Online` |
| `ui_health` | `OK` |

Se `ui_health` for `FAIL`, espere e rode de novo. Se continuar: veja [§8 Troubleshooting](#8-troubleshooting).

### 3.4 Publicar DAGs e abrir a UI

```powershell
.\scripts\sync-dags.ps1
```

```powershell
# URL (IP muda após stop/start)
terraform -chdir=terraform output -raw airflow_ui_url

# Senha admin (usuário: admin)
aws ssm get-parameter `
  --name "$(terraform -chdir=terraform output -raw airflow_ui_password_ssm_param)" `
  --with-decryption --query Parameter.Value --output text
```

No browser: `http://<public_ip>:8080` → login `admin` + senha do SSM.  
DAG E2E: `lab_pipeline_e2e` (aparece em até ~5 min após o sync).

---

## 4. Rotina diária de estudo

### Ligar (começar o estudo)

```powershell
cd D:\projetos-ia-aws\ia-dlc-mwaa
.\scripts\airflow-ec2-start.ps1
# Aguarde 5–15 min (Compose sobe de novo)
.\scripts\airflow-ec2-status.ps1
```

**Importante:** o **IP público muda** a cada start. Pegue a URL nova no status ou:

```powershell
terraform -chdir=terraform output -raw airflow_ui_url
# Se o output ainda mostrar IP antigo, use o public_ip do status script
```

Metadata do Airflow (Postgres no volume EBS) **sobrevive** ao stop/start. DAGs no disco local da instância são re-sincronizados do S3 (timer a cada 5 min) — rode `.\scripts\sync-dags.ps1` se precisar imediato.

### Desligar (terminar o estudo)

```powershell
.\scripts\airflow-ec2-stop.ps1
```

Isso **para** a EC2 (não apaga disco nem o restante da VPC). Use sempre que for parar por horas/dias.

### Status a qualquer momento

```powershell
.\scripts\airflow-ec2-status.ps1
```

### Shell na EC2 (sem SSH)

```powershell
aws ssm start-session --target "$(terraform -chdir=terraform output -raw airflow_ec2_instance_id)"
```

Dentro da sessão (exemplos):

```bash
sudo tail -f /var/log/airflow-ec2-bootstrap.log
sudo docker compose -f /opt/airflow-ec2/docker-compose.yml --env-file /opt/airflow-ec2/.env ps
```

---

## 5. O que estudar em cada camada

### U1 — Orquestrador (Airflow EC2)

| Ação | Comando / onde |
|---|---|
| Ver UI / DAGs | Browser `:8080` |
| Publicar DAG | Coloque `.py` em `dags/` → `.\scripts\sync-dags.ps1` |
| Logs do host | SSM + `journalctl` / bootstrap log |
| Parar custo EC2 | `.\scripts\airflow-ec2-stop.ps1` |

### U2 — Data lake e governança

```powershell
# Seed CSV de exemplo em raw/dt=...
bash scripts/seed-sample.sh
# ou, se bash não estiver ok no PATH do PS, use Git Bash / WSL

aws glue start-crawler --name "$(terraform -chdir=terraform output -raw raw_crawler_name)"
```

Depois: Console Athena → workgroup do output `athena_workgroup_name` → consultar tabelas do Glue DB `glue_database_name`.

### U3 — Compute (Lambda / Glue / ECS)

```powershell
# Preferível Git Bash / WSL se o script .sh exigir bash:
bash scripts/smoke-compute.sh
```

Isso invoca Lambda marker, sobe Glue Job e dispara task ECS Fargate.

### Outputs úteis

```powershell
cd terraform
terraform output
```

| Output | Para quê |
|---|---|
| `airflow_ui_url` / `airflow_ec2_public_ip` | Abrir UI |
| `airflow_ui_password_ssm_param` | Login admin |
| `airflow_ec2_instance_id` | start/stop/SSM |
| `orchestrator_role_arn` | Quem orquestra lake/compute |
| `artifact_bucket_name` | DAGs / compose |
| `data_lake_bucket_name` | Dados raw/processed |
| `lambda_function_name`, `glue_job_name`, `ecs_*` | Smoke U3 |

---

## 6. Tabela de scripts (PowerShell vs Bash)

| Objetivo | PowerShell (Windows) | Bash (Git Bash / WSL*) |
|---|---|---|
| Apply Terraform | `.\scripts\apply.ps1` | `bash scripts/apply.sh` |
| Status EC2 + UI | `.\scripts\airflow-ec2-status.ps1` | `bash scripts/airflow-ec2-status.sh` |
| Ligar EC2 | `.\scripts\airflow-ec2-start.ps1` | `bash scripts/airflow-ec2-start.sh` |
| Desligar EC2 | `.\scripts\airflow-ec2-stop.ps1` | `bash scripts/airflow-ec2-stop.sh` |
| Sync DAGs | `.\scripts\sync-dags.ps1` | `bash scripts/sync-dags.sh` |
| Set Airflow Variables | `.\scripts\set-airflow-variables.ps1` | `bash scripts/set-airflow-variables.sh` |
| Seed lake | — | `bash scripts/seed-sample.sh` |
| Smoke compute | — | `bash scripts/smoke-compute.sh` |

---

\* No WSL, o Terraform precisa estar instalado **dentro do WSL** ou use PowerShell.

---

## 6.1 U4 — Pipeline E2E + SNS

### Fluxo

1. Apply Terraform (módulo SNS + IAM `sns:Publish` + pacote Compose no S3)
2. Sync DAGs: `.\scripts\sync-dags.ps1` (envia `dags/` + `requirements.txt`)
3. Aguarde `ui_health: OK` (`.\scripts\airflow-ec2-status.ps1`)
4. Se a EC2 já estava up **antes** de mudar `requirements.txt` ou arquivos em `airflow_ec2/files/`: re-bootstrap (ver [postmortem](runbooks/airflow-ec2-bootstrap-postmortem.md))
5. Gerar comandos de Variables: `.\scripts\set-airflow-variables.ps1`
6. SSM na EC2 → `docker exec` no container **scheduler** → colar os `airflow variables set ...`
7. UI → unpause + **Trigger** `lab_pipeline_e2e`
8. Verificar SNS (Console → Topics → `{prefix}pipeline-status`) ou e-mail se configurou `sns_notification_email`
9. Opcional SELECT: `airflow variables set lab_e2e_enable_select 'true'` **após** `seed-sample.sh` + crawler

### Requirements (provider Amazon)

- Pin: `apache-airflow-providers-amazon==8.28.0` (compatível Airflow **2.11.2**)
- Bootstrap usa `pip install --no-deps --target /opt/airflow/python-packages` — **não** use faixas `>=9` (puxam Airflow 3.x)

### Custo marginal U4

SNS + Athena queries de exemplo: tipicamente **centavos** por sessão. Schedule default off (`lab_e2e_schedule` vazio).

### RTO

Se a EC2 estiver stopped, a pipeline fica indisponível até `.\scripts\airflow-ec2-start.ps1` (RTO ≈ tempo de start + Compose healthy).

### Outputs úteis

| Output | Uso |
|---|---|
| `sns_topic_arn` / `sns_topic_name` | Verificar notificações |
| `airflow_variables_map` | Input do script set-airflow-variables |

---

## 7. Checklist “sessão de estudo”
**Abrir sessão**

1. `.\scripts\airflow-ec2-start.ps1`
2. Esperar `ui_health: OK` (`.\scripts\airflow-ec2-status.ps1`)
3. Pegar senha SSM + abrir UI no IP atual
4. `.\scripts\sync-dags.ps1` se alterou arquivos em `dags/`

**Fechar sessão**

1. Confirmar que Glue/ECS jobs terminaram (Console)
2. `.\scripts\airflow-ec2-stop.ps1`
3. Não deixar a UI aberta em IP antigo (ele deixa de valer)

**Fim do lab / liberar quase tudo**

```powershell
cd terraform
terraform destroy -var-file=terraform.tfvars
```

Isso remove VPC, NAT, EC2, buckets (conteúdo), etc. **Irreversível** para dados no state.

---

## 8. Troubleshooting

> **Postmortem detalhado (CRLF, volume `.local`, pip Airflow 3.x):**  
> [`docs/runbooks/airflow-ec2-bootstrap-postmortem.md`](runbooks/airflow-ec2-bootstrap-postmortem.md)

### `terraform: command not found` no `bash scripts/...`

Use PowerShell: `.\scripts\apply.ps1`. O WSL não herda o PATH do Chocolatey.

### `set: pipefail` / `bash\r` / script `.sh` abre o VS Code

**Causa:** fim de linha **CRLF** em scripts enviados ao S3/EC2 (comum ao editar no Windows).

**Prevenção:**

- `.gitattributes` força LF em `*.sh` e `terraform/modules/airflow_ec2/files/**`.
- Após editar bootstrap/compose, rode `.\scripts\apply.ps1` (atualiza objetos S3).
- No PowerShell, rode `.ps1`, não dê duplo clique em `.sh`.

**Sintoma:** `/usr/log/user-data.log` → `bash\r: No such file or directory`; bootstrap log ausente.

### `InvalidParameterCombination` / Free Tier

Use `airflow_instance_type = "t3.small"` (ou `t3.micro`) no `terraform.tfvars` e reaplique.

### `ui_health: FAIL` / `ERR_CONNECTION_TIMED_OUT`

1. Confirme o IP público **atual** (`curl.exe -s ifconfig.me`) — se mudou (VPN on/off), atualize `operator_cidr` em `terraform.tfvars` e rode `.\scripts\apply.ps1`.
2. Confirme a URL **atual** (`.\scripts\airflow-ec2-status.ps1`) — IP da EC2 muda após stop/start.
3. Bootstrap lento (5–15 min). Se persistir: SSM → `sudo tail -f /var/log/airflow-ec2-bootstrap.log`.
4. Se apply **substituiu** a EC2 (AMI drift): espere bootstrap completo de novo.

### `airflow: command not found` no bootstrap

**Causa:** volume `python-packages` montado em `/home/airflow/.local` (versão antiga do compose).

**Fix no repo:** montar em `/opt/airflow/python-packages` + `PYTHONPATH`. Re-bootstrap via SSM (ver postmortem).

### Webserver em crash loop / `airflow webserver has been removed`

**Causa:** `pip install` do provider Amazon puxou **Airflow 3.x** para `PYTHONPATH` (requirements com `>=9` sem `--no-deps`).

**Fix no repo:** pin `apache-airflow-providers-amazon==8.28.0` + `pip install --no-deps`. Confirme:

```bash
docker exec airflow-ec2-airflow-scheduler-1 airflow version
# deve ser 2.11.2, não 3.x
```

### `NoRegionError: You must specify a region`

**Causa:** containers Airflow usam instance role, mas **não tinham** `AWS_REGION` / `AWS_DEFAULT_REGION` no Compose.

**Fix no repo:** `docker-compose.yml` exporta a região; `.env` do bootstrap inclui `AWS_REGION`; DAG usa `region_name` / `boto3.client(..., region_name=...)`; Variable `lab_aws_region`.

Após mudar Compose em EC2 já up: sync + `docker compose up -d` (ou re-bootstrap).

### `NoCredentialsError: Unable to locate credentials`

**Causa:** IMDS hop limit = **1** — containers Docker não alcançam `169.254.169.254` (instance role).

**Fix no repo:** `metadata_options.http_put_response_hop_limit = 2` no módulo EC2.

Aplicação imediata (sem recreate):

```powershell
aws ec2 modify-instance-metadata-options `
  --instance-id "$(terraform -chdir=terraform output -raw airflow_ec2_instance_id)" `
  --http-put-response-hop-limit 2 --http-tokens required
```

Confirme no scheduler: `boto3.client("sts").get_caller_identity()` deve retornar a role `*-airflow-ec2-execution`.

### UI pede senha e a do SSM ainda é `placeholder-change-on-boot`

Bootstrap ainda não reescreveu o parâmetro — aguarde o fim do bootstrap ou reinicie a instância após o pacote Compose estar no S3.

### IP da UI “não abre”

IP antigo após stop/start. Rode status de novo e use o **public_ip** atual.

### MWAA / `SubscriptionRequiredException`

Ignore no modo `ec2`. Só use `orchestrator_mode=mwaa` se a conta tiver assinatura MWAA.

---

## 9. Segurança mínima (lab)

- Restrinja `operator_cidr` ao seu IP `/32` (não deixe `0.0.0.0/0` em Wi‑Fi público).
- Sem SSH: só SSM.
- Senha da UI só no SSM Parameter Store — não commit em git.
- `terraform.tfvars` e `*.tfstate` estão (ou devem estar) fora do git / com cuidado.

---

## 10. Glossário curto

| Termo | Significado |
|---|---|
| **Apply** | Criar/atualizar recursos AWS via Terraform |
| **Stop EC2** | Desliga a VM; para cobrança de compute; EBS permanece |
| **Start EC2** | Religa; novo IP público; Compose sobe de novo |
| **Destroy** | Apaga a stack Terraform |
| **Sync DAGs** | Copia `dags/` do PC → bucket S3 → EC2 puxa a cada 5 min |
| **Bootstrap** | Script de first-boot: Docker, Compose, senha UI |

---

## Referência rápida (copiar / colar)

```powershell
cd D:\projetos-ia-aws\ia-dlc-mwaa

# Ligar
.\scripts\airflow-ec2-start.ps1
.\scripts\airflow-ec2-status.ps1

# Estudar
.\scripts\sync-dags.ps1
# abrir http://<ip>:8080  user=admin  senha=SSM

# Desligar (fim do dia)
.\scripts\airflow-ec2-stop.ps1
```
