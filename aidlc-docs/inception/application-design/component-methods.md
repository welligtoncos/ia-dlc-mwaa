# Component Methods

Nível: operações Terraform/AWS de alto nível **e** tasks do DAG (PipelineApp).  
Regras de negócio detalhadas → Functional Design (Construction).

## NetworkFabric
| Method | Input | Output | Purpose |
|---|---|---|---|
| `provision_vpc` | cidrs, azs, tags | vpc_id | Cria VPC com DNS |
| `provision_subnets` | vpc_id, cidrs | subnet_ids | 2 private + 1 public |
| `provision_nat_path` | public_subnet_id | nat_id, private_rt | 1 NAT + rotas |
| `provision_mwaa_sg` | vpc_id | sg_id | SG mínimo MWAA |

## ArtifactStore
| Method | Input | Output | Purpose |
|---|---|---|---|
| `create_bucket` | name_prefix, tags | bucket_id, arn | Bucket versionado + BPA |
| `expose_mwaa_paths` | bucket_id | s3_uris | URIs dags/plugins/requirements |

## DataLakeStore
| Method | Input | Output | Purpose |
|---|---|---|---|
| `create_lake_bucket` | name_prefix, tags | bucket_id, arn | Lake + BPA + versioning |
| `define_prefixes` | bucket_id | raw, processed, athena_results | Layout lógico |

## OrchestratorMWAA
| Method | Input | Output | Purpose |
|---|---|---|---|
| `create_environment` | name, version, class, subnet_ids, sg, source_bucket, exec_role | env_arn, webserver_url | Provisiona MWAA |
| `configure_logging` | env | log_groups | Logs CW |
| `ignore_artifact_versions` | — | lifecycle meta | ignore requirements/plugins object versions |

## IdentityPlane
| Method | Input | Output | Purpose |
|---|---|---|---|
| `build_mwaa_execution_policy` | bucket ARNs, service ARNs | policy_json | Least privilege cross-service |
| `attach_mwaa_policies` | role_name, policies | — | Anexa ao execution role MWAA |
| `export_terraform_apply_policy` | service list | policy file | Doc/policy do principal apply |

## ServerlessExecutor
| Method | Input | Output | Purpose |
|---|---|---|---|
| `create_function` | runtime, handler, role | function_arn | Lambda exemplo |
| `create_execution_role` | log/s3 needs | role_arn | Role local do serviço |

## EtlExecutor
| Method | Input | Output | Purpose |
|---|---|---|---|
| `create_job` | script_uri, role, lake paths | job_name | Glue Job exemplo |
| `create_job_role` | lake/catalog ARNs | role_arn | Role local |

## CatalogService
| Method | Input | Output | Purpose |
|---|---|---|---|
| `create_database` | name | database_name | Glue DB |
| `create_crawler` | s3_target, role, db | crawler_name | Crawler raw/ |

## ContainerExecutor
| Method | Input | Output | Purpose |
|---|---|---|---|
| `create_cluster` | name | cluster_arn | ECS cluster |
| `register_task_definition` | image, cpu/mem, roles | task_def_arn | Fargate task PoC |
| `create_task_roles` | needs | exec_role, task_role | Roles locais |

## GovernancePlane
| Method | Input | Output | Purpose |
|---|---|---|---|
| `register_location` | s3_arn | location | LF resource link |
| `create_lf_tags` | tag map | tag_keys | LF-Tags |
| `associate_tags` | resource, tags | — | Associa tags |
| `grant_permissions` | principal, permissions, resource | — | Grants mínimos |

## QueryService
| Method | Input | Output | Purpose |
|---|---|---|---|
| `create_workgroup` | name, output_uri | workgroup | Athena workgroup |

## NotifyService
| Method | Input | Output | Purpose |
|---|---|---|---|
| `create_topic` | name | topic_arn | SNS |
| `optional_email_subscription` | email var | subscription | Se email não vazio |

## PipelineApp (DAG tasks / “methods”)
| Method (task) | Input | Output | Purpose |
|---|---|---|---|
| `sync_artifacts` (ops) | local dags/, bucket | — | `aws s3 sync` (fora do TF) |
| `task_invoke_lambda` | function_name | payload/status | US-06 |
| `task_start_glue_job` | job_name | job_run_id | US-07 |
| `task_run_ecs_fargate` | cluster, task_def, subnets | task_arn | US-07 |
| `task_athena_query` | workgroup, sql | query_id | US-09 |
| `task_publish_sns` | topic_arn, message | — | US-09 sucesso/falha |
| `on_failure_callback` | context | — | Notifica falha |
