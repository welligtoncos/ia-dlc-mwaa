# modules/glue_job — Glue ETL passthrough (U3).

variable "name_prefix" {
  type = string
}

variable "job_name" {
  type = string
}

variable "artifact_bucket_name" {
  type = string
}

variable "artifact_bucket_arn" {
  type = string
}

variable "data_lake_bucket_name" {
  type = string
}

variable "data_lake_bucket_arn" {
  type = string
}

variable "script_source_path" {
  type        = string
  description = "Local path to Glue Python script."
}

variable "glue_version" {
  type    = string
  default = "4.0"
}

variable "worker_type" {
  type    = string
  default = "G.1X"
}

variable "number_of_workers" {
  type    = number
  default = 2
}

variable "aws_region" {
  type = string
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "assume" {
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
  name               = "${var.name_prefix}glue-passthrough"
  assume_role_policy = data.aws_iam_policy_document.assume.json

  tags = {
    Name = "${var.name_prefix}glue-passthrough"
  }
}

data "aws_iam_policy_document" "glue" {
  statement {
    sid    = "ScriptRead"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = [
      var.artifact_bucket_arn,
      "${var.artifact_bucket_arn}/scripts/*",
    ]
  }

  statement {
    sid    = "LakeReadWrite"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket"
    ]
    resources = [
      var.data_lake_bucket_arn,
      "${var.data_lake_bucket_arn}/*",
    ]
  }

  statement {
    sid    = "GlueLogs"
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

  statement {
    sid    = "GlueCatalogMinimal"
    effect = "Allow"
    actions = [
      "glue:GetDatabase",
      "glue:GetTable",
      "glue:GetTables",
      "glue:CreateTable",
      "glue:UpdateTable",
      "glue:GetPartition",
      "glue:GetPartitions",
      "glue:BatchCreatePartition"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "glue" {
  name   = "${var.name_prefix}glue-passthrough"
  role   = aws_iam_role.glue.id
  policy = data.aws_iam_policy_document.glue.json
}

resource "aws_s3_object" "script" {
  bucket = var.artifact_bucket_name
  key    = "scripts/glue_passthrough.py"
  source = var.script_source_path
  etag   = filemd5(var.script_source_path)
}

resource "aws_glue_job" "passthrough" {
  name     = var.job_name
  role_arn = aws_iam_role.glue.arn

  glue_version      = var.glue_version
  worker_type       = var.worker_type
  number_of_workers = var.number_of_workers
  max_retries       = 0
  timeout           = 20

  command {
    name            = "glueetl"
    python_version  = "3"
    script_location = "s3://${var.artifact_bucket_name}/${aws_s3_object.script.key}"
  }

  default_arguments = {
    "--job-language"                     = "python"
    "--enable-metrics"                   = "true"
    "--enable-continuous-cloudwatch-log" = "true"
    "--DATA_LAKE_BUCKET"                 = var.data_lake_bucket_name
    "--RAW_PREFIX"                       = "raw"
    "--PROCESSED_PREFIX"                 = "processed"
  }

  execution_property {
    max_concurrent_runs = 1
  }

  tags = {
    Name = var.job_name
  }

  depends_on = [aws_iam_role_policy.glue, aws_s3_object.script]
}

output "job_name" {
  value = aws_glue_job.passthrough.name
}

output "job_arn" {
  value = aws_glue_job.passthrough.arn
}

output "role_arn" {
  value = aws_iam_role.glue.arn
}

output "role_name" {
  value = aws_iam_role.glue.name
}

output "script_s3_uri" {
  value = "s3://${var.artifact_bucket_name}/${aws_s3_object.script.key}"
}
