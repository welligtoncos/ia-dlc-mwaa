# modules/glue_catalog — Glue Database + 2 crawlers on-demand + role de serviço (U2).

variable "name_prefix" {
  type = string
}

variable "database_name" {
  type        = string
  description = "Nome do Glue Database (underscores; sem hífens)."
}

variable "data_bucket_name" {
  type = string
}

variable "data_bucket_arn" {
  type = string
}

variable "aws_region" {
  type = string
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "glue_assume" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["glue.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "glue" {
  name               = "${var.name_prefix}glue-service"
  assume_role_policy = data.aws_iam_policy_document.glue_assume.json

  tags = {
    Name = "${var.name_prefix}glue-service"
  }
}

# Least privilege: S3 data lake + logs de crawler + Glue catalog APIs necessárias.
data "aws_iam_policy_document" "glue" {
  statement {
    sid    = "DataLakeReadWrite"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket"
    ]
    resources = [
      var.data_bucket_arn,
      "${var.data_bucket_arn}/*",
    ]
  }

  statement {
    sid    = "GlueCatalog"
    effect = "Allow"
    actions = [
      "glue:GetDatabase",
      "glue:GetDatabases",
      "glue:CreateTable",
      "glue:UpdateTable",
      "glue:GetTable",
      "glue:GetTables",
      "glue:GetPartition",
      "glue:GetPartitions",
      "glue:BatchCreatePartition",
      "glue:BatchDeletePartition",
      "glue:BatchGetPartition",
      "glue:CreatePartition",
      "glue:UpdatePartition",
      "glue:DeletePartition",
      "glue:BatchDeleteTable"
    ]
    resources = [
      "arn:aws:glue:${var.aws_region}:${data.aws_caller_identity.current.account_id}:catalog",
      "arn:aws:glue:${var.aws_region}:${data.aws_caller_identity.current.account_id}:database/${var.database_name}",
      "arn:aws:glue:${var.aws_region}:${data.aws_caller_identity.current.account_id}:table/${var.database_name}/*",
    ]
  }

  statement {
    sid    = "CrawlerLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws-glue/*"
    ]
  }

  # Lake Formation data access quando o location está registrado no LF.
  statement {
    sid       = "LakeFormationGetDataAccess"
    effect    = "Allow"
    actions   = ["lakeformation:GetDataAccess"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "glue" {
  name   = "${var.name_prefix}glue-service"
  role   = aws_iam_role.glue.id
  policy = data.aws_iam_policy_document.glue.json
}

resource "aws_glue_catalog_database" "lake" {
  name = var.database_name

  description = "U2 data lake catalog database"
}

resource "aws_glue_crawler" "raw" {
  name          = "${var.name_prefix}raw-crawler"
  role          = aws_iam_role.glue.arn
  database_name = aws_glue_catalog_database.lake.name

  # Sem schedule — on-demand (headroom documentado no README).
  s3_target {
    path = "s3://${var.data_bucket_name}/raw/"
  }

  schema_change_policy {
    delete_behavior = "LOG"
    update_behavior = "UPDATE_IN_DATABASE"
  }

  tags = {
    Name = "${var.name_prefix}raw-crawler"
  }

  depends_on = [aws_iam_role_policy.glue]
}

resource "aws_glue_crawler" "processed" {
  name          = "${var.name_prefix}processed-crawler"
  role          = aws_iam_role.glue.arn
  database_name = aws_glue_catalog_database.lake.name

  s3_target {
    path = "s3://${var.data_bucket_name}/processed/"
  }

  schema_change_policy {
    delete_behavior = "LOG"
    update_behavior = "UPDATE_IN_DATABASE"
  }

  tags = {
    Name = "${var.name_prefix}processed-crawler"
  }

  depends_on = [aws_iam_role_policy.glue]
}

output "database_name" {
  value = aws_glue_catalog_database.lake.name
}

output "raw_crawler_name" {
  value = aws_glue_crawler.raw.name
}

output "processed_crawler_name" {
  value = aws_glue_crawler.processed.name
}

output "glue_service_role_arn" {
  value = aws_iam_role.glue.arn
}

output "glue_service_role_name" {
  value = aws_iam_role.glue.name
}
