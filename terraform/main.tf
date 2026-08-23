# main.tf
# Orquestra U1 + U2:
#   Network → ArtifactStore → Identity → MWAA
#   DataLake → GlueCatalog → LakeFormation → Athena (+ IAM lake na execution role)

locals {
  name_prefix = "${var.project_name}-${var.environment}-"
  # Glue DB não aceita hífens — sanitiza o prefixo.
  glue_database_name = coalesce(
    var.glue_database_name,
    "${replace(trimsuffix(local.name_prefix, "-"), "-", "_")}_lake"
  )
  athena_workgroup_name = coalesce(
    var.athena_workgroup_name,
    "${trimsuffix(local.name_prefix, "-")}-dev"
  )
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

# --- U2 Data Lake and Governance ---

module "data_lake" {
  source = "./modules/data_lake"

  name_prefix                    = local.name_prefix
  data_bucket_name               = "${local.name_prefix}data-${random_id.bucket_suffix.hex}"
  athena_results_bucket_name     = "${local.name_prefix}athena-results-${random_id.bucket_suffix.hex}"
  athena_results_expiration_days = 7
}

module "glue_catalog" {
  source = "./modules/glue_catalog"

  name_prefix      = local.name_prefix
  database_name    = local.glue_database_name
  data_bucket_name = module.data_lake.data_bucket_name
  data_bucket_arn  = module.data_lake.data_bucket_arn
  aws_region       = var.aws_region
}

module "lake_formation" {
  source = "./modules/lake_formation"

  name_prefix             = local.name_prefix
  data_bucket_arn         = module.data_lake.data_bucket_arn
  glue_database_name      = module.glue_catalog.database_name
  glue_role_arn           = module.glue_catalog.glue_service_role_arn
  mwaa_execution_role_arn = module.identity.execution_role_arn
  project_tag_value       = "ia-dlc-mwaa"
}

module "athena" {
  source = "./modules/athena"

  name_prefix                = local.name_prefix
  workgroup_name             = local.athena_workgroup_name
  athena_results_bucket_name = module.data_lake.athena_results_bucket_name
}

# Policy aditiva na execution role MWAA — S3 lake/results + Glue/Athena/LF (U2; sem Action "*").
data "aws_iam_policy_document" "mwaa_lake_access" {
  statement {
    sid    = "DataLakeObjects"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]
    resources = [
      module.data_lake.data_bucket_arn,
      "${module.data_lake.data_bucket_arn}/*",
      module.data_lake.athena_results_bucket_arn,
      "${module.data_lake.athena_results_bucket_arn}/*",
    ]
  }

  statement {
    sid    = "GlueCatalogRead"
    effect = "Allow"
    actions = [
      "glue:GetDatabase",
      "glue:GetDatabases",
      "glue:GetTable",
      "glue:GetTables",
      "glue:GetPartition",
      "glue:GetPartitions",
      "glue:BatchGetPartition"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "AthenaQuery"
    effect = "Allow"
    actions = [
      "athena:StartQueryExecution",
      "athena:StopQueryExecution",
      "athena:GetQueryExecution",
      "athena:GetQueryResults",
      "athena:GetWorkGroup",
      "athena:ListWorkGroups",
      "athena:GetDataCatalog",
      "athena:ListDataCatalogs"
    ]
    resources = ["*"]
  }

  statement {
    sid       = "LakeFormationGetDataAccess"
    effect    = "Allow"
    actions   = ["lakeformation:GetDataAccess"]
    resources = ["*"]
  }

  statement {
    sid    = "StartCrawlers"
    effect = "Allow"
    actions = [
      "glue:StartCrawler",
      "glue:GetCrawler",
      "glue:GetCrawlerMetrics"
    ]
    resources = [
      "arn:aws:glue:${var.aws_region}:*:crawler/${module.glue_catalog.raw_crawler_name}",
      "arn:aws:glue:${var.aws_region}:*:crawler/${module.glue_catalog.processed_crawler_name}",
    ]
  }

  statement {
    sid     = "PassGlueCrawlerRole"
    effect  = "Allow"
    actions = ["iam:PassRole"]
    resources = [
      module.glue_catalog.glue_service_role_arn,
    ]
    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["glue.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "mwaa_lake_access" {
  name   = "${local.name_prefix}mwaa-lake-access"
  role   = module.identity.execution_role_name
  policy = data.aws_iam_policy_document.mwaa_lake_access.json
}
