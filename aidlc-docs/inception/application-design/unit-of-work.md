# Units of Work

**Projeto**: ia-dlc-mwaa  
**Decomposição**: 4 unidades (módulos lógicos; um serviço Terraform implantável)  
**Deploy**: 1 root · 1 state local · 1 apply  
**Dependências**: U1 → (U2 ∥ U3) → U4

## Code Organization Strategy (Greenfield)

```
ia-dlc-mwaa/
  terraform/
    versions.tf
    providers.tf
    variables.tf
    outputs.tf
    main.tf                 # wiring dos modules
    modules/
      network/              # U1
      artifact_store/       # U1
      mwaa/                 # U1
      identity/             # U1 (+ grants cross-service U3)
      data_lake/            # U2
      glue_catalog/         # U2
      lake_formation/       # U2
      athena/               # U2
      lambda_executor/      # U3
      glue_job/             # U3
      ecs_executor/         # U3
      sns/                  # U4
  dags/                     # U4 PipelineApp
  requirements.txt          # U4
  policies/
    terraform-apply-policy.json   # U1 / US-04
  README.md
  aidlc-docs/               # documentação AI-DLC only
```

**Regra**: código de aplicação/IaC nunca dentro de `aidlc-docs/`.

---

## U1 — Foundation (Platform)

| Campo | Valor |
|---|---|
| **Tipo** | Módulo lógico / foundation package |
| **Bounded context** | Platform |
| **Owner lógico** | P1 Platform Engineer |
| **Componentes** | NetworkFabric, ArtifactStore, OrchestratorMWAA, IdentityPlane (base MWAA + apply policy) |
| **Responsabilidade** | Rede mínima, bucket de artefatos Airflow, ambiente MWAA `mw1.small`, IAM base least privilege, policy documentada do `terraform apply` |
| **Entregáveis** | `modules/network`, `artifact_store`, `mwaa`, `identity` (+ `policies/terraform-apply-policy.json`) |
| **Stories** | US-01, US-02, US-03, US-04, parte US-10 |
| **Done when** | MWAA healthy, UI PUBLIC acessível, bucket pronto para sync, apply policy revisável |

---

## U2 — Data Lake and Governance

| Campo | Valor |
|---|---|
| **Tipo** | Módulo lógico |
| **Bounded context** | Governance / Lake |
| **Owner lógico** | P3 Security/Governance |
| **Componentes** | DataLakeStore, CatalogService, GovernancePlane, QueryService |
| **Responsabilidade** | Lake S3 (raw/processed/athena-results), Glue DB/Crawler, Lake Formation + LF-Tags/grants, Athena workgroup |
| **Entregáveis** | `modules/data_lake`, `glue_catalog`, `lake_formation`, `athena` |
| **Stories** | US-08, US-09 (parte Athena) |
| **Done when** | Location LF registrada, tags/grants mínimos, workgroup Athena com output no lake |
| **Depende de** | U1 (tags/vars/provider; opcionalmente network só se endpoints futuros — não bloqueante para S3/Glue/Athena APIs) |

---

## U3 — Compute Executors

| Campo | Valor |
|---|---|
| **Tipo** | Módulo lógico |
| **Bounded context** | Compute |
| **Owner lógico** | P2 Data Engineer |
| **Componentes** | ServerlessExecutor, EtlExecutor, ContainerExecutor + grants MWAA→compute (IdentityPlane extensão) |
| **Responsabilidade** | Lambda exemplo, Glue Job exemplo, ECS Fargate task exemplo; roles locais + permissões de invocação para MWAA |
| **Entregáveis** | `modules/lambda_executor`, `glue_job`, `ecs_executor` (+ updates em `identity`) |
| **Stories** | US-06, US-07, parte US-10 |
| **Done when** | Três executors invocáveis pela execution role do MWAA com least privilege |
| **Depende de** | U1 (MWAA role, network para ECS); pode paralelizar com U2 (lake paths via vars/outputs) |

---

## U4 — Orchestration and Notify

| Campo | Valor |
|---|---|
| **Tipo** | Módulo lógico + app code |
| **Bounded context** | Orchestration |
| **Owner lógico** | P2 Data Engineer |
| **Componentes** | PipelineApp, NotifyService |
| **Responsabilidade** | DAG E2E, requirements, SNS, docs de `aws s3 sync` e smoke test |
| **Entregáveis** | `dags/`, `requirements.txt`, `modules/sns`, seções README (sync/apply/smoke) |
| **Stories** | US-05, US-09 (parte SNS), fechamento E2E |
| **Done when** | Após sync, DAG executa Lambda+Glue+ECS+Athena e publica SNS |
| **Depende de** | U1 + U2 + U3 |

---

## Unit Summary

| ID | Name | Parallelizable with |
|---|---|---|
| U1 | Foundation | — (first) |
| U2 | Data Lake and Governance | U3 (após U1) |
| U3 | Compute Executors | U2 (após U1) |
| U4 | Orchestration and Notify | — (last) |
