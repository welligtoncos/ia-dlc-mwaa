# Instruções de Build

**Stack:** U1 EC2 Airflow + U2 Data Lake + U3 Compute + **U4 SNS/DAG E2E**  
**Ferramenta:** Terraform ≥ 1.5 · AWS CLI v2 · PowerShell (Windows)

## Pré-requisitos

| Item | Nota |
|---|---|
| AWS credenciais | `aws sts get-caller-identity` |
| `terraform.tfvars` | `operator_cidr`, `airflow_instance_type` (ex. `m7i-flex.large`) |
| Opcional | `sns_notification_email` para subscription e-mail |
| LF admin | Conta com Data Lake administrator (U2) |

## Etapas de Build

### 1. Format + validate

```powershell
cd D:\projetos-ia-aws\ia-dlc-mwaa\terraform
terraform fmt -recursive
terraform init -input=false
terraform validate
```

**Esperado:** `Success! The configuration is valid.`

### 2. Plan / Apply (U4 delta)

```powershell
cd D:\projetos-ia-aws\ia-dlc-mwaa
.\scripts\apply.ps1
```

**Artefatos esperados no apply U4:**
- SNS topic `{prefix}pipeline-status` (+ subscription se e-mail setado)
- IAM policy `orchestrator-sns-publish` na role EC2
- Refresh S3 `airflow-ec2/` (bootstrap + requirements + compose)
- Outputs: `sns_topic_arn`, `airflow_variables_map`

### 3. Sync artefatos de aplicação

```powershell
.\scripts\sync-dags.ps1
```

Sincroniza `dags/` + `requirements.txt` → ArtifactStore.

### 4. Runtime provider (se EC2 já estava up)

SSM na EC2 e re-bootstrap **ou** re-run pip + restart Compose (ver `docs/lab-guide.md` §6.1).

### 5. Verificar sucesso

```powershell
.\scripts\airflow-ec2-status.ps1
terraform -chdir=terraform output sns_topic_arn
terraform -chdir=terraform output -json airflow_variables_map
```

## Solução de problemas

| Sintoma | Ação |
|---|---|
| Module sns not installed | `terraform init` |
| UI timeout | Atualizar `operator_cidr` + apply |
| Import error amazon provider | Re-run bootstrap pip / restart Compose |
| Variable missing no DAG | `.\scripts\set-airflow-variables.ps1` → colar via SSM |
