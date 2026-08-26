# U1-orchestrator-ec2 — Code Generation Summary

**Date**: 2026-08-24  
**Mode default**: `orchestrator_mode=ec2`

## Generated / Modified Artifacts

| Path | Change |
|---|---|
| `terraform/variables.tf` | `orchestrator_mode`, `operator_cidr`, `airflow_instance_type`, `airflow_image_digest` |
| `terraform/main.tf` | Conditional MWAA vs EC2 modules; `orchestrator_role_*` locals; lake/compute IAM rewire |
| `terraform/outputs.tf` | Generic orchestrator outputs + EC2-specific outputs |
| `terraform/modules/airflow_ec2_identity/` | EC2 role, instance profile, SSM core, S3/SSM base policies |
| `terraform/modules/airflow_ec2/` | EC2, SG, alarm, SSM param, S3 compose package, user_data bootstrap |
| `terraform/modules/airflow_ec2/files/` | docker-compose.yml, bootstrap.sh, systemd units |
| `scripts/airflow-ec2-start.sh` | Start instance |
| `scripts/airflow-ec2-stop.sh` | Stop instance |
| `scripts/airflow-ec2-status.sh` | EC2 + SSM + UI health |
| `dags/placeholder_smoke.py` | Minimal listable DAG |
| `README.md` | EC2 operation section |

## Apply (EC2 mode)

```bash
bash scripts/apply.sh -- -var='operator_cidr=YOUR_IP/32'
bash scripts/sync-dags.sh
bash scripts/airflow-ec2-status.sh
```

## Post-apply validation

1. EC2 `running`; SSM `Online` within ~2 min
2. Bootstrap completes (~5–10 min): UI `http://<public_ip>:8080/health` OK
3. Login `admin` + password from SSM param `airflow_ui_password_ssm_param`
4. `placeholder_smoke` visible after DAG sync (≤5 min timer or manual sync)

## Migration note

Existing state with MWAA/identity modules will show destroy/recreate when switching to `orchestrator_mode=ec2`. Expected for this pivot.

## Operator / study docs

- Guia completo (ligar / usar / desligar): `docs/lab-guide.md`
- README aponta o fluxo PowerShell diário

## Out of scope (U4+)

- SNS on CW alarm
- Full E2E orchestration DAG
- MWAA apply when Free Tier blocked
