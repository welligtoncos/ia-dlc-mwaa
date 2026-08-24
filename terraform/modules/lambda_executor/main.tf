# modules/lambda_executor — Lambda marker (U3). Sem VPC.

variable "name_prefix" {
  type = string
}

variable "function_name" {
  type = string
}

variable "data_lake_bucket_name" {
  type = string
}

variable "data_lake_bucket_arn" {
  type = string
}

variable "memory_size" {
  type    = number
  default = 256
}

variable "timeout_seconds" {
  type    = number
  default = 60
}

variable "source_dir" {
  type        = string
  description = "Path to Lambda source directory (handler.py)."
}

data "aws_iam_policy_document" "assume" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda" {
  name               = "${var.name_prefix}lambda-marker"
  assume_role_policy = data.aws_iam_policy_document.assume.json

  tags = {
    Name = "${var.name_prefix}lambda-marker"
  }
}

data "aws_iam_policy_document" "lambda" {
  statement {
    sid    = "Logs"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:log-group:/aws/lambda/${var.function_name}*"]
  }

  statement {
    sid    = "LakeRawWrite"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = [
      var.data_lake_bucket_arn,
      "${var.data_lake_bucket_arn}/raw/*",
    ]
  }
}

resource "aws_iam_role_policy" "lambda" {
  name   = "${var.name_prefix}lambda-marker"
  role   = aws_iam_role.lambda.id
  policy = data.aws_iam_policy_document.lambda.json
}

data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = var.source_dir
  output_path = "${path.module}/build/lambda_marker.zip"
}

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = 14
}

resource "aws_lambda_function" "marker" {
  function_name    = var.function_name
  role             = aws_iam_role.lambda.arn
  handler          = "handler.handler"
  runtime          = "python3.12"
  filename         = data.archive_file.lambda.output_path
  source_code_hash = data.archive_file.lambda.output_base64sha256
  memory_size      = var.memory_size
  timeout          = var.timeout_seconds

  environment {
    variables = {
      DATA_LAKE_BUCKET = var.data_lake_bucket_name
      RAW_PREFIX       = "raw"
    }
  }

  depends_on = [
    aws_iam_role_policy.lambda,
    aws_cloudwatch_log_group.lambda,
  ]

  tags = {
    Name = var.function_name
  }
}

output "function_name" {
  value = aws_lambda_function.marker.function_name
}

output "function_arn" {
  value = aws_lambda_function.marker.arn
}

output "role_arn" {
  value = aws_iam_role.lambda.arn
}

output "role_name" {
  value = aws_iam_role.lambda.name
}
