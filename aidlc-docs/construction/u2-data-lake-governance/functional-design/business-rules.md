# U2 Data Lake and Governance — Business Rules

## BR-LAKE — Data storage

| ID | Rule |
|---|---|
| BR-LAKE-01 | Existem **dois buckets**: DataLake (dados) e AthenaResults (resultados). |
| BR-LAKE-02 | DataLake usa prefixos `raw/` e `processed/` (não misturar resultados Athena). |
| BR-LAKE-03 | Versionamento e Block Public Access obrigatórios em ambos os buckets. |
| BR-LAKE-04 | Terraform **não** faz upload de dataset de negócio; seed é manual/documentado. |
| BR-LAKE-05 | Buckets de lake são distintos do ArtifactStore da U1 (DAGs). |

## BR-CAT — Catalog / Crawlers

| ID | Rule |
|---|---|
| BR-CAT-01 | Um Glue Database por ambiente (ex.: `{prefix}lake`). |
| BR-CAT-02 | Dois crawlers: um para `raw/`, um para `processed/`. |
| BR-CAT-03 | Crawler roles com least privilege só no prefixo alvo + Glue Catalog. |
| BR-CAT-04 | Aceite: após seed + crawler run, tabelas aparecem no Catalog. |

## BR-LF — Lake Formation / LF-Tags (US-08)

| ID | Rule |
|---|---|
| BR-LF-01 | Locations do DataLake registradas no Lake Formation. |
| BR-LF-02 | LF-Tags obrigatórias: `Classification` (`raw`\|`processed`) e `Project` (`ia-dlc-mwaa`). |
| BR-LF-03 | Tags associadas no mínimo a database e/ou locations/tabelas demonstráveis. |
| BR-LF-04 | Grants **direcionados** (não `ALL` amplo no database como padrão didático). |
| BR-LF-05 | Principals mínimos: crawler role(s), query/Athena path, **MWAA execution role** (prep U4). |
| BR-LF-06 | Conta deve ter Data Lake administrator configurado **antes** do apply (pré-req manual). |

## BR-ATH — Athena (US-09 parcial)

| ID | Rule |
|---|---|
| BR-ATH-01 | Workgroup nomeado `dev` (ou `{prefix}dev`) — não usar só `primary`. |
| BR-ATH-02 | `enforce_workgroup_configuration = true`. |
| BR-ATH-03 | Output location aponta para o **AthenaResultsStore** (bucket separado). |
| BR-ATH-04 | Consultas de lab usam o workgroup `dev` e tabelas do Glue Database U2. |

## BR-INT — Integração U1/U4

| ID | Rule |
|---|---|
| BR-INT-01 | U2 consome `name_prefix`, tags, region e `mwaa_execution_role_arn` da U1. |
| BR-INT-02 | Grants MWAA na U2 cobrem leitura Catalog/lake + StartQuery Athena necessários ao DAG futuro. |
| BR-INT-03 | Sem SNS nesta unidade (U4). |

## Story Coverage

| Story | Rules |
|---|---|
| US-08 | BR-LF-*, BR-LAKE-*, BR-CAT-* |
| US-09 (Athena) | BR-ATH-*, BR-LAKE-01/AthenaResults |
| Prep U4 | BR-INT-02 |
