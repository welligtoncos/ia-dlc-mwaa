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
