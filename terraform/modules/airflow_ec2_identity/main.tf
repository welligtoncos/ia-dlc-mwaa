# modules/airflow_ec2_identity — EC2 orchestrator execution role (U1-orchestrator-ec2).
# Lake/compute policies attach at root via orchestrator_role_arn.

variable "name_prefix" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "artifact_bucket_arn" {
  type = string
}

variable "ssm_password_parameter_name" {
  type        = string
  description = "SSM Parameter path for Airflow UI password (SecureString)."
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "ec2_assume" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "airflow_ec2_execution" {
  name               = "${var.name_prefix}airflow-ec2-execution"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json

  tags = {
    Name       = "${var.name_prefix}airflow-ec2-execution"
    CostCenter = "lab"
  }
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.airflow_ec2_execution.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy_document" "airflow_ec2_base" {
  statement {
    sid    = "ArtifactBucketList"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
    ]
    resources = [var.artifact_bucket_arn]
  }

  statement {
    sid    = "ArtifactBucketObjects"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
    ]
    resources = [
      "${var.artifact_bucket_arn}/airflow-ec2/*",
      "${var.artifact_bucket_arn}/dags/*",
      "${var.artifact_bucket_arn}/plugins/*",
      "${var.artifact_bucket_arn}/requirements.txt",
    ]
  }

  statement {
    sid    = "UiPasswordParameter"
    effect = "Allow"
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:PutParameter",
    ]
    resources = [
      "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter${var.ssm_password_parameter_name}",
    ]
  }
}

resource "aws_iam_role_policy" "airflow_ec2_base" {
  name   = "${var.name_prefix}airflow-ec2-base"
  role   = aws_iam_role.airflow_ec2_execution.id
  policy = data.aws_iam_policy_document.airflow_ec2_base.json
}

resource "aws_iam_instance_profile" "airflow_ec2" {
  name = "${var.name_prefix}airflow-ec2-profile"
  role = aws_iam_role.airflow_ec2_execution.name

  tags = {
    Name       = "${var.name_prefix}airflow-ec2-profile"
    CostCenter = "lab"
  }
}

output "role_arn" {
  value = aws_iam_role.airflow_ec2_execution.arn
}

output "role_name" {
  value = aws_iam_role.airflow_ec2_execution.name
}

output "instance_profile_name" {
  value = aws_iam_instance_profile.airflow_ec2.name
}

output "ssm_password_parameter_name" {
  value = var.ssm_password_parameter_name
}
