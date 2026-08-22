# U1 Foundation — Code Generation Summary

## Created (application / IaC at workspace root)

| Path | Purpose |
|---|---|
| `terraform/versions.tf` | TF >= 1.5, AWS ~> 5.0, random |
| `terraform/providers.tf` | AWS provider + default tags |
| `terraform/variables.tf` | Vars com descriptions/defaults |
| `terraform/outputs.tf` | Contrato shared U2–U4 |
| `terraform/main.tf` | Wiring modules |
| `terraform/modules/network/` | VPC, NAT, SG, S3 endpoint |
| `terraform/modules/artifact_store/` | Bucket SSE-S3 + bootstrap objects |
| `terraform/modules/identity/` | MWAA execution role least privilege |
| `terraform/modules/mwaa/` | MWAA env + lifecycle ignore |
| `policies/terraform-apply-policy.json` | Policy operador apply U1–U4 |
| `policies/README.md` | Explicação Sids |
| `scripts/apply.sh` | Apply com retry/backoff |
| `scripts/sync-dags.sh` | Sync dags → S3 |
| `README.md` | Runbook |
| `.gitignore` | state/terraform |
| `dags/.gitkeep` | Placeholder |
| `requirements.txt` | Placeholder |

## Stories covered
US-01, US-02, US-03, US-04, US-10 (base)

## Notes
- Bootstrap S3 objects (`.gitkeep` / requirements placeholder) existem só para o create do MWAA não falhar por path ausente; DAGs de negócio ficam na U4 + `sync-dags.sh`.
- `Action: "*"` não é usado; alguns `Resource: "*"` com actions nomeadas seguem limites das APIs AWS / guia MWAA.
