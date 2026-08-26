# Instruções de Testes End-to-End

**Escopo:** plataforma completa U1–U4 (`lab_pipeline_e2e` + SNS).

---

## E2E-1 — Airflow + DAG sync

```powershell
cd D:\projetos-ia-aws\ia-dlc-mwaa
.\scripts\airflow-ec2-start.ps1   # se stopped
.\scripts\airflow-ec2-status.ps1
.\scripts\sync-dags.ps1
```

1. Login UI `admin` + senha SSM  
2. Confirmar DAG **`lab_pipeline_e2e`** (não `placeholder_smoke`)

**Aceite:** DAG listado e paused/unpaused conforme esperado.

---

## E2E-2 — Variables + provider

1. `.\scripts\set-airflow-variables.ps1` → colar via SSM  
2. Se import falhar no DAG: re-bootstrap / pip requirements (§6.1 lab-guide)  
3. Unpause DAG

**Aceite:** DAG sem import errors; Variables `lab_*` presentes.

---

## E2E-3 — Pipeline feliz (sem SELECT)

1. UI → Trigger `lab_pipeline_e2e`  
2. Tasks: Lambda → Glue ∥ ECS → Athena SHOW → skip_select → SNS success  
3. Console SNS → mensagem `status=success` (ou e-mail se inscrito)

**Aceite:** run `success` + SNS success (BR-ACCEPT-01).

---

## E2E-4 — Falha observável

1. Temporariamente setar Variable inválida (ex. lambda name errado) **ou** forçar falha em uma task  
2. Trigger run  
3. Confirmar SNS `status=failed` + `failed_task_id`

**Aceite:** callback SNS failed (BR-ACCEPT-02).

---

## E2E-5 — SELECT opcional (não gate)

1. `bash scripts/seed-sample.sh` + crawler  
2. `airflow variables set lab_e2e_enable_select 'true'`  
3. Trigger novamente → sensor + SELECT + SNS

**Aceite:** SELECT executa; **não** obrigatório para fechar U4.

---

## E2E-6 — Paths manuais legados (regressão)

| ID | Script / ação |
|---|---|
| Data path | `seed-sample.sh` + Athena |
| Compute path | `smoke-compute.sh` |

Opcional se E2E-3 passou.

---

## Cleanup

```powershell
.\scripts\airflow-ec2-stop.ps1
```
