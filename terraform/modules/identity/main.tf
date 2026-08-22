# modules/identity — execution role MWAA com least privilege base (U1).
# Grants U2–U4 serão policies adicionais anexadas depois — não Admin.

variable "name_prefix" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "artifact_bucket_arn" {
  type = string
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "mwaa_assume" {
  statement {
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = [
        "airflow.amazonaws.com",
        "airflow.${var.aws_region}.amazonaws.com",
      ]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "mwaa_execution" {
  name               = "${var.name_prefix}mwaa-execution"
  assume_role_policy = data.aws_iam_policy_document.mwaa_assume.json

  tags = {
    Name = "${var.name_prefix}mwaa-execution"
  }
}

# Policy base: S3 artefatos + logs + permissões de serviço MWAA necessárias.
# Resources escopados ao bucket e à conta/região — sem Action "*".
data "aws_iam_policy_document" "mwaa_execution" {
  # List bucket (MWAA discovery)
  statement {
    sid       = "ArtifactBucketList"
    effect    = "Allow"
    actions   = ["s3:ListAllMyBuckets"]
    resources = ["*"]
  }

  statement {
    sid    = "ArtifactBucketObjects"
    effect = "Allow"
    actions = [
      "s3:GetObject*",
      "s3:GetBucket*",
      "s3:List*",
      "s3:PutObject*"
    ]
    resources = [
      var.artifact_bucket_arn,
      "${var.artifact_bucket_arn}/*",
    ]
  }

  statement {
    sid    = "CloudWatchLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:PutLogEvents",
      "logs:GetLogEvents",
      "logs:GetLogRecord",
      "logs:GetLogGroupFields",
      "logs:GetQueryResults",
      "logs:DescribeLogGroups"
    ]
    resources = [
      "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:airflow-${var.name_prefix}*"
    ]
  }

  statement {
    sid    = "CloudWatchMetrics"
    effect = "Allow"
    actions = [
      "cloudwatch:PutMetricData"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "cloudwatch:namespace"
      values   = ["AmazonMWAA"]
    }
  }

  statement {
    sid    = "AirflowSqs"
    effect = "Allow"
    actions = [
      "sqs:ChangeMessageVisibility",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ReceiveMessage",
      "sqs:SendMessage"
    ]
    resources = [
      "arn:aws:sqs:${var.aws_region}:*:airflow-celery-*"
    ]
  }

  # KMS via SQS/S3 — padrão AWS MWAA; Resource "*" limitado por kms:ViaService (não é Action "*").
  statement {
    sid    = "KmsAirflow"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:GenerateDataKey*",
      "kms:Encrypt"
    ]
    resources = ["*"]
    condition {
      test     = "StringLike"
      variable = "kms:ViaService"
      values = [
        "sqs.${var.aws_region}.amazonaws.com",
        "s3.${var.aws_region}.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role_policy" "mwaa_execution" {
  name   = "${var.name_prefix}mwaa-execution"
  role   = aws_iam_role.mwaa_execution.id
  policy = data.aws_iam_policy_document.mwaa_execution.json
}

output "execution_role_arn" {
  value = aws_iam_role.mwaa_execution.arn
}

output "execution_role_name" {
  value = aws_iam_role.mwaa_execution.name
}
