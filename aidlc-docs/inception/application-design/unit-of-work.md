# Units of Work

**Projeto**: ia-dlc-mwaa  
**Decomposição**: 4 unidades (módulos lógicos; um serviço Terraform implantável)  
**Deploy**: 1 root · 1 state local · 1 apply  
**Dependências**: U1 → (U2 ∥ U3) → U4  

> **Amendment**: U1 default entrega **OrchestratorEC2** (`modules/airflow_ec2`). MWAA só se `orchestrator_mode=mwaa`.

## Code Organization Strategy

```
ia-dlc-mwaa/
  terraform/
    modules/
      network/              # U1
      artifact_store/       # U1
      airflow_ec2/          # U1 (default orchestrator)
      mwaa/                 # U1 (optional mode=mwaa)
      identity/             # U1 (+ EC2 role / optional MWAA role)
      data_lake/            # U2
      glue_catalog/         # U2
      lake_formation/       # U2
      athena/               # U2
      lambda_executor/      # U3
      glue_job/             # U3
      ecs_executor/         # U3
      sns/                  # U4
  dags/                     # U4 PipelineApp
  scripts/                  # sync-dags, airflow-ec2-start/stop, apply
  aidlc-docs/
```

---

## U1 — Foundation (Platform)

| Campo | Valor |
|---|---|
| **Tipo** | Módulo lógico / foundation package |
| **Bounded context** | Platform |
| **Owner lógico** | P1 Platform Engineer |
| **Componentes** | NetworkFabric, ArtifactStore, **OrchestratorEC2** (default), OrchestratorMWAA (optional), IdentityPlane, DagSyncAgent |
| **Responsabilidade** | Rede, bucket artefatos (+ compose package), EC2 Airflow Compose **ou** MWAA conforme mode, IAM principal ativo, apply policy |
| **Entregáveis** | `modules/network`, `artifact_store`, **`airflow_ec2`**, `mwaa` (gated), `identity`, scripts start/stop |
| **Stories** | US-01, US-02, US-03, US-04, parte US-10 |
| **Done when (default ec2)** | EC2 running Compose; UI :8080 reachable from operator_cidr; SSM works; bucket ready for sync; instance role can call U2/U3 APIs |
| **Done when (mode mwaa)** | MWAA healthy + UI PUBLIC_ONLY (conta com assinatura) |

### U1-orchestrator-ec2 (delta Construction)
Mesma U1; foco Construction desta mudança: módulo EC2, IAM EC2, SG, compose upload, scripts, conditional MWAA off.

---

## U2 — Data Lake and Governance

(Inalterado em escopo.) Done when LF/Athena ok. Depende de U1 tags/vars.

---

## U3 — Compute Executors

| Campo | Valor |
|---|---|
| **Done when** | Três executors invocáveis pela **role do orquestrador ativo** (EC2 default / MWAA se mode=mwaa) |
| **Depende de** | U1 (orchestrator role, network para ECS) |

---

## U4 — Orchestration and Notify

| Campo | Valor |
|---|---|
| **Responsabilidade** | DAG E2E, SNS, docs sync + UI EC2 + smoke |
| **Done when** | Após sync, DAG E2E no Airflow EC2 (ou MWAA) + SNS |

---

## Unit Summary

| ID | Name | Parallelizable with |
|---|---|---|
| U1 | Foundation (+ orchestrator-ec2 delta) | — |
| U2 | Data Lake and Governance | U3 (após U1) |
| U3 | Compute Executors | U2 (após U1) |
| U4 | Orchestration and Notify | — (last) |
