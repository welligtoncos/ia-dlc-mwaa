# U2 Data Lake and Governance — Business Logic Model

## Purpose
Modelar o provisionamento e as capacidades de **data lake + catálogo + governança LF + consulta Athena**, sem detalhe de sintaxe Terraform.

## Primary Flow — Provision Lake & Governance

```
1. Load PlatformContext from U1 (name_prefix, tags, region, mwaa_execution_role_arn)
2. Provision DataLakeStore (dados: raw/, processed/)
3. Provision AthenaResultsStore (bucket separado de resultados)
4. Provision CatalogService (Glue DB + crawlers raw e processed)
5. Provision GovernancePlane (register locations, LF-Tags, grants)
6. Provision QueryService (Athena workgroup → AthenaResultsStore)
7. Attach grants for MWAA execution role (prepare U4)
8. Publish LakeOutputs for U3/U4
```

## Capability Behaviors

### DataLakeStore
- Bucket de dados com prefixos lógicos `raw/` e `processed/`.
- Versioning + BPA + encryption (detalhe NFR/infra).
- **Não** recebe dataset de exemplo via provisionamento (upload manual).

### AthenaResultsStore
- Bucket dedicado a query results do Athena.
- Isola lifecycle/custo de resultados do lake de dados.

### CatalogService
- Glue Database único.
- Crawler `raw` → `s3://data-lake/raw/`.
- Crawler `processed` → `s3://data-lake/processed/`.
- Produz tabelas no Catalog após run (operação pós-upload).

### GovernancePlane
- Registra locations S3 do data lake (e, se necessário, policy alinhada a LF).
- LF-Tags: `Classification` ∈ {raw, processed}, `Project` = `ia-dlc-mwaa`.
- Associa tags a databases/tables/locations no mínimo demonstrável.
- Grants fine-grained a: crawler role, Athena/query principals, **MWAA execution role**.

### QueryService
- Workgroup Athena `dev` com `enforce_workgroup_configuration`.
- Output location = AthenaResultsStore.
- Consultas assumem tabelas governadas no Catalog.

## Operator Flows (post-provision)

| Flow | Steps |
|---|---|
| Seed sample | Upload CSV/Parquet manual em `raw/` (doc README) |
| Discover schema | Start crawler raw (e processed quando houver dados) |
| Query | Athena workgroup `dev` sobre tabelas catalogadas |
| Orchestrate later | U4 DAG usa MWAA role já com grants U2 |

## Error Semantics
- Falha de apply → abort (sem compensação automática).
- Conta sem Data Lake administrator → grants LF falham; pré-req manual documentado.
- Crawler sem objetos em `raw/` → run “vazio”/sem tabelas (esperado até seed).

## Outputs for Downstream
| Output | Consumers |
|---|---|
| data_lake_bucket | U3 Glue Job, U4 DAG |
| athena_results_bucket | U4 Athena tasks |
| glue_database_name | U3/U4 |
| athena_workgroup | U4 |
| lf_tag_keys | docs / U4 |
| mwaa grants applied | U4 |
