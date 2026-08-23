# U2 Data Lake and Governance — Domain Entities

## DataLakeBucket
| Attribute | Type | Notes |
|---|---|---|
| name | string | `{prefix}data-lake-...` |
| rawPrefix | string | `raw/` |
| processedPrefix | string | `processed/` |
| versioning | bool | true |
| publicAccessBlocked | bool | true |

## AthenaResultsBucket
| Attribute | Type | Notes |
|---|---|---|
| name | string | `{prefix}athena-results-...` |
| purpose | enum | query_results_only |
| versioning | bool | true |
| publicAccessBlocked | bool | true |

## GlueCatalogDatabase
| Attribute | Type | Notes |
|---|---|---|
| name | string | e.g. `ia_dlc_mwaa_dev_lake` |
| description | string | lab lake catalog |

## GlueCrawler
| Attribute | Type | Notes |
|---|---|---|
| name | string | `...-crawler-raw` / `...-crawler-processed` |
| targetPrefix | string | `raw/` or `processed/` |
| databaseName | ref | GlueCatalogDatabase |
| roleArn | arn | crawler execution role |

## LfTag
| Attribute | Type | Notes |
|---|---|---|
| key | string | `Classification` or `Project` |
| values | list | Classification: raw, processed; Project: ia-dlc-mwaa |

## LfLocationRegistration
| Attribute | Type | Notes |
|---|---|---|
| s3Arn | arn | DataLake bucket/prefixes |
| roleArn | arn | optional service role if used |

## LfGrant
| Attribute | Type | Notes |
|---|---|---|
| principalArn | arn | MWAA / crawler / query |
| permissions | list | e.g. DESCRIBE, SELECT (mínimo) |
| resource | ref | database / table / tag expression |

## AthenaWorkgroup
| Attribute | Type | Notes |
|---|---|---|
| name | string | `dev` or prefixed |
| outputBucket | ref | AthenaResultsBucket |
| enforceConfiguration | bool | true |
| state | enum | ENABLED |

## Relationships

```
PlatformContext(U1) 1--* DataLakeBucket
PlatformContext(U1) 1--* AthenaResultsBucket
DataLakeBucket 1--* GlueCrawler
GlueCatalogDatabase 1--* GlueCrawler
DataLakeBucket 1--* LfLocationRegistration
LfTag *--* GlueCatalogDatabase / tables / locations
LfGrant *--* principals (MWAA role, crawler roles)
AthenaWorkgroup *--1 AthenaResultsBucket
AthenaWorkgroup *--1 GlueCatalogDatabase (logical queries)
```

## Invariants
- AthenaResultsBucket ≠ DataLakeBucket ≠ U1 ArtifactBucket.
- Todo grant LF de lab referencia principals do stack (sem wildcard de conta).
- Sem Data Lake admin pré-configurado, GovernancePlane não é considerado “done”.
