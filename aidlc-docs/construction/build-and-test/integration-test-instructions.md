# Instruções de Testes de Integração

## Propósito
Validar U1↔U2↔U3↔U4: orquestrador EC2, lake/Athena, executors e SNS.

## Cenário 1 — U1 orquestrador + UI

**Setup:** EC2 running; `operator_cidr` correto.

```powershell
.\scripts\airflow-ec2-status.ps1
```

1. `ui_health: OK`
2. Login admin + senha SSM
3. DAG `lab_pipeline_e2e` listado (após sync)

**Aceite:** UI alcançável; DAG presente.

---

## Cenário 2 — Artifact sync

```powershell
.\scripts\sync-dags.ps1
```

Aguardar timer 5 min **ou** sync forçado na EC2. Confirmar arquivo no bucket `dags/lab_pipeline_e2e.py`.

**Aceite:** DAG aparece na UI após parse.

---

## Cenário 3 — Variables binding

```powershell
.\scripts\set-airflow-variables.ps1
```

Colar comandos via SSM no container scheduler. Em UI Admin → Variables, confirmar keys `lab_*`.

**Aceite:** `lab_sns_topic_arn`, `lab_lambda_function_name`, etc. preenchidos.

---

## Cenário 4 — U2 data path

```bash
bash scripts/seed-sample.sh
# start crawler raw (AWS Console ou CLI)
```

**Aceite:** tabelas no Glue DB (necessário só se `lab_e2e_enable_select=true`).

---

## Cenário 5 — U3 compute (fora do DAG)

```bash
bash scripts/smoke-compute.sh
```

**Aceite:** Lambda/Glue/ECS concluem; markers no lake (opcional se E2E DAG cobrir).

---

## Cenário 6 — U4 SNS IAM

1. Confirmar topic policy permite só `orchestrator_role_arn`
2. Role tem policy `…orchestrator-sns-publish`

**Aceite:** Publish do DAG não retorna AccessDenied.

---

## Ordem sugerida

1 → 2 → 3 → (4 opcional) → 6 → E2E completo (`e2e-test-instructions.md`)
