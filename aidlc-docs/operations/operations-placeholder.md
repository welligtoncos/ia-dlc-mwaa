# Operations — Placeholder

**Status:** Esta fase do AI-DLC ainda não implementa deploy/monitoramento automatizado.  
**Data:** 2026-08-26  
**Construction:** U1–U4 **concluídos** (código + instruções build/test).

## O que existe hoje (operacional manual)

| Área | Onde |
|---|---|
| Ligar/desligar EC2 | `docs/lab-guide.md`, `scripts/airflow-ec2-*.ps1` |
| Sync DAGs + requirements | `scripts/sync-dags.ps1` |
| Airflow Variables (print → SSM) | `scripts/set-airflow-variables.ps1` |
| Build/apply | `scripts/apply.ps1` |
| Pipeline E2E | DAG `lab_pipeline_e2e` + SNS (`docs/lab-guide.md` §6.1) |
| Smoke / integração / E2E | `aidlc-docs/construction/build-and-test/` |
| Custo | AWS Billing / Cost Explorer; stop EC2 ao idle |
| Destroy stack | `terraform destroy -var-file=terraform.tfvars` |

## Runbook mínimo diário

```powershell
.\scripts\airflow-ec2-start.ps1
.\scripts\airflow-ec2-status.ps1
.\scripts\sync-dags.ps1
.\scripts\set-airflow-variables.ps1   # se outputs mudaram
# UI → trigger lab_pipeline_e2e → verificar SNS
.\scripts\airflow-ec2-stop.ps1
```

## Futuro (Operations expandido)

- Amarrar alarme EC2 status-check → SNS (opt-in)
- Runbooks de incidente formalizados
- Backup state Terraform remoto
- CI/CD apply
- Observabilidade centralizada (logs/metrics)

## Estado do produto

| Unidade | Status |
|---|---|
| U1 Foundation / EC2 Airflow | Done |
| U2 Data Lake / Athena / LF | Done |
| U3 Compute executors | Done |
| U4 Orchestration and Notify | Done (apply + E2E runtime = checklist operador) |
