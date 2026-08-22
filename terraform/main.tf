# main.tf
# Orquestra U1: Network → ArtifactStore → Identity → MWAA (ordem lógica de dependência).

locals {
  name_prefix = "${var.project_name}-${var.environment}-"
}

# random_id: S3 bucket names são globais; sufixo evita colisão sem hardcode de conta.
resource "random_id" "bucket_suffix" {
  byte_length = 2
}

module "network" {
  source = "./modules/network"

  name_prefix          = local.name_prefix
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidr   = var.public_subnet_cidr
  private_subnet_cidrs = var.private_subnet_cidrs
  aws_region           = var.aws_region
}

module "artifact_store" {
  source = "./modules/artifact_store"

  name_prefix = local.name_prefix
  # bucket globalmente único
  bucket_name = "${local.name_prefix}artifacts-${random_id.bucket_suffix.hex}"
}

module "identity" {
  source = "./modules/identity"

  name_prefix         = local.name_prefix
  aws_region          = var.aws_region
  artifact_bucket_arn = module.artifact_store.bucket_arn
  # account id via data source no módulo
}

module "mwaa" {
  source = "./modules/mwaa"

  name_prefix           = local.name_prefix
  environment_name      = "${local.name_prefix}env"
  airflow_version       = var.airflow_version
  environment_class     = var.environment_class
  webserver_access_mode = var.webserver_access_mode
  source_bucket_arn     = module.artifact_store.bucket_arn
  execution_role_arn    = module.identity.execution_role_arn
  subnet_ids            = module.network.private_subnet_ids
  security_group_ids    = [module.network.mwaa_security_group_id]
}
