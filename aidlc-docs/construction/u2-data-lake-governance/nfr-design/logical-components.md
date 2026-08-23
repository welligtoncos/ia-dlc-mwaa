# U2 Data Lake and Governance — Logical NFR Components

## Component Catalog

### SecurityBaseline
- **Responsibility**: Controles de segurança nos stores e transporte.
- **Implements**: BPA total; SSE-S3; bucket policy deny insecure transport; tags de ownership; sample sem dados sensíveis.
- **Collaborates with**: DataLakeStore, AthenaResultsStore, GovernanceBoundary.
- **Infra mapping (next stage)**: `aws_s3_bucket_*` + bucket policies nos modules `data_lake`.

### CatalogBoundary
- **Responsibility**: Fronteira de descoberta de schema.
- **Implements**: Glue Database; crawlers raw/processed on-demand; paths raiz `raw/` e `processed/` com **layout Hive-style** documentado (`dt=YYYY-MM-DD/` sob cada raiz).
- **Collaborates with**: DataLakeStore, GovernanceBoundary, OperatorTooling (seed path).
- **Scale knobs**: vars de nomes/paths; schedule = headroom doc only.
- **Infra mapping**: module `glue_catalog`.

### GovernanceBoundary
- **Responsibility**: Controles Lake Formation (tags + grants).
- **Implements**: Register S3 locations; LF-Tags Classification/Project; grants a crawler role, Athena principals, MWAA execution role.
- **Prerequisite**: Data Lake administrator na conta (manual).
- **Collaborates with**: CatalogBoundary, Identity (U1 MWAA role ARN), QueryBoundary.
- **Infra mapping**: module `lake_formation`.

### QueryBoundary
- **Responsibility**: Fronteira de consulta governada.
- **Implements**: Athena workgroup `dev` → AthenaResultsStore; enforce workgroup configuration.
- **Collaborates with**: CatalogBoundary, SecurityBaseline (results bucket).
- **Infra mapping**: module `athena`.

### CostGuardrail
- **Responsibility**: Limitar custo de resultados e superfície lab.
- **Implements**: Lifecycle expire **7 dias** no results bucket; crawlers on-demand (sem schedule pago recorrente); 2 buckets explícitos (isola custo de results).
- **Collaborates with**: QueryBoundary, SecurityBaseline.
- **Infra mapping**: lifecycle rule em `data_lake` (results bucket).

### OperatorTooling
- **Responsibility**: Usabilidade operacional U2.
- **Implements**: README (LF admin, seed, start crawlers, Athena query); `scripts/seed-sample.sh` com retry/backoff de upload para path Hive de exemplo.
- **Out of scope U2**: alarmes SNS; wrapper StartCrawler pós-apply.
- **Infra mapping**: docs + script na Code Generation.

## Logical View

```
+------------------+     +------------------+
| OperatorTooling  |     |  CostGuardrail   |
+--------+---------+     +--------+---------+
         |                        |
         v                        v
+--------+------------------------+---------+
|           SecurityBaseline                |
+----+-------------+-------------+----------+
     |             |             |
     v             v             v
+----+-----+  +----+-----+  +----+------+
| Catalog  |  |Governance|  |  Query    |
| Boundary |--| Boundary |--| Boundary  |
+----+-----+  +----------+  +----+------+
     |                            |
     v                            v
 DataLakeStore              AthenaResultsStore
 (raw/ + processed/         (lifecycle 7d)
  Hive dt= partitions)
```

## Hive Path Convention (Q3=B)

| Zone | Example object key |
|---|---|
| raw | `raw/dt=2026-08-23/sample.csv` |
| processed | `processed/dt=2026-08-23/...` (U3 writers) |

Crawlers target zone roots; partition keys discovered when present.

## Implementation Notes for Infrastructure Design
1. Modules: `data_lake`, `glue_catalog`, `lake_formation`, `athena` + root wiring to U1 outputs.
2. Bucket policies: deny non-TLS on data + results.
3. Lifecycle 7d only on Athena results bucket.
4. Crawler S3 targets: `raw/` and `processed/` prefixes (not per-dt).
5. Seed script uploads into `raw/dt=<today>/`.
6. Não criar `schedule` nos crawlers; documentar headroom no README.
7. Grants MWAA exec role nesta unidade (consumidores U4).
