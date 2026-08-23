# outputs.tf
# Contrato compartilhado para U2–U4 (ver aidlc-docs/construction/shared-infrastructure.md).

output "name_prefix" {
  description = "Prefixo {project}-{env}-"
  value       = local.name_prefix
}

output "aws_region" {
  description = "Região efetiva"
  value       = var.aws_region
}

output "vpc_id" {
  description = "VPC compartilhada"
  value       = module.network.vpc_id
}

output "private_subnet_ids" {
  description = "Subnets privadas (MWAA / futuros tasks ECS)"
  value       = module.network.private_subnet_ids
}

output "public_subnet_id" {
  description = "Subnet pública (NAT)"
  value       = module.network.public_subnet_id
}

output "mwaa_security_group_id" {
  description = "Security group do MWAA"
  value       = module.network.mwaa_security_group_id
}

output "artifact_bucket_name" {
  description = "Bucket de DAGs/plugins/requirements"
  value       = module.artifact_store.bucket_name
}

output "artifact_bucket_arn" {
  description = "ARN do bucket de artefatos"
  value       = module.artifact_store.bucket_arn
}

output "mwaa_environment_name" {
  description = "Nome do ambiente MWAA"
  value       = module.mwaa.environment_name
}

output "mwaa_environment_arn" {
  description = "ARN do ambiente MWAA"
  value       = module.mwaa.environment_arn
}

output "mwaa_webserver_url" {
  description = "URL da UI Airflow (PUBLIC_ONLY)"
  value       = module.mwaa.webserver_url
}

output "mwaa_execution_role_arn" {
  description = "Execution role do MWAA (U2–U4 anexam policies adicionais)"
  value       = module.identity.execution_role_arn
}

# --- U2 outputs (contrato shared) ---

output "data_lake_bucket_name" {
  description = "Bucket do data lake (raw/ + processed/)"
  value       = module.data_lake.data_bucket_name
}

output "data_lake_bucket_arn" {
  description = "ARN do bucket do data lake"
  value       = module.data_lake.data_bucket_arn
}

output "athena_results_bucket_name" {
  description = "Bucket de resultados Athena (lifecycle 7d)"
  value       = module.data_lake.athena_results_bucket_name
}

output "athena_results_bucket_arn" {
  description = "ARN do bucket de resultados Athena"
  value       = module.data_lake.athena_results_bucket_arn
}

output "glue_database_name" {
  description = "Glue Catalog database"
  value       = module.glue_catalog.database_name
}

output "raw_crawler_name" {
  description = "Crawler raw (on-demand)"
  value       = module.glue_catalog.raw_crawler_name
}

output "processed_crawler_name" {
  description = "Crawler processed (on-demand)"
  value       = module.glue_catalog.processed_crawler_name
}

output "glue_service_role_arn" {
  description = "IAM role dos crawlers Glue"
  value       = module.glue_catalog.glue_service_role_arn
}

output "athena_workgroup_name" {
  description = "Athena workgroup (enforce → results bucket)"
  value       = module.athena.workgroup_name
}

output "lf_tag_classification_key" {
  description = "LF-Tag Classification"
  value       = module.lake_formation.lf_tag_classification_key
}

output "lf_tag_project_key" {
  description = "LF-Tag Project"
  value       = module.lake_formation.lf_tag_project_key
}
