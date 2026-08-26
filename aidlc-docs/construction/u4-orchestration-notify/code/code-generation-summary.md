# U4-orchestration-notify — Code Generation Summary

**Unit**: U4 Orchestration and Notify  
**Status**: Part 2 executed  
**Validate**: `terraform validate` OK (after `terraform init`)

## Deliverables

| Path | Change |
|---|---|
| `terraform/modules/sns/main.tf` | Topic + optional email sub + topic policy |
| `terraform/main.tf` | `module.sns` + IAM `orchestrator_sns_publish` |
| `terraform/variables.tf` | `sns_notification_email` |
| `terraform/outputs.tf` | `sns_topic_*`, `airflow_variables_map` |
| `requirements.txt` (+ package copy) | `apache-airflow-providers-amazon` pin |
| `modules/airflow_ec2/files/bootstrap.sh` | `pip install -r` into `python-packages` |
| `modules/airflow_ec2/files/docker-compose.yml` | Mount `python-packages` |
| `dags/lab_pipeline_e2e.py` | E2E DAG (Lambda → Glue∥ECS → Athena → SNS) |
| `dags/placeholder_smoke.py` | **Removed** |
| `scripts/set-airflow-variables.ps1` / `.sh` | Emit `airflow variables set` |
| `README.md`, `docs/lab-guide.md` | U4 E2E operator flow |

## Operator next steps

1. `.\scripts\apply.ps1`
2. `.\scripts\sync-dags.ps1`
3. Re-bootstrap / restart Compose if EC2 already running (pip providers)
4. `.\scripts\set-airflow-variables.ps1` → paste via SSM
5. Trigger `lab_pipeline_e2e` in UI
6. Confirm SNS message

## Notes

- Athena/`glue:GetTable` reused from existing `mwaa_lake_access` (no rewrite).
- `airflow_ec2_identity` module untouched (IAM U4 in root).
- U1 status-check alarm still has no SNS action.
