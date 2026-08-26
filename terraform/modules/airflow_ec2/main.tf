# modules/airflow_ec2 — EC2 host + SG + Compose package + bootstrap (U1-orchestrator-ec2).

locals {
  compose_files = fileset("${path.module}/files", "**")
  ssm_param     = var.ssm_password_parameter_name
}

data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-kernel-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "airflow_ec2" {
  name        = "${var.name_prefix}airflow-ec2"
  description = "Airflow UI :8080 from operator_cidr; SSM egress"
  vpc_id      = var.vpc_id

  ingress {
    description = "Airflow UI"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.operator_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name       = "${var.name_prefix}airflow-ec2"
    CostCenter = "lab"
  }
}

resource "aws_ssm_parameter" "ui_password_placeholder" {
  name        = local.ssm_param
  description = "Airflow UI admin password (overwritten by bootstrap on first boot)"
  type        = "SecureString"
  value       = "placeholder-change-on-boot"

  tags = {
    Name       = "${var.name_prefix}airflow-ui-password"
    CostCenter = "lab"
  }

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_s3_object" "compose_package" {
  for_each = local.compose_files

  bucket = var.artifact_bucket_name
  key    = "airflow-ec2/${each.value}"
  source = "${path.module}/files/${each.value}"
  etag   = filemd5("${path.module}/files/${each.value}")
}

resource "aws_instance" "airflow" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.airflow_ec2.id]
  iam_instance_profile        = var.instance_profile_name
  associate_public_ip_address = true

  user_data = templatefile("${path.module}/templates/user_data.sh.tpl", {
    artifact_bucket      = var.artifact_bucket_name
    aws_region           = var.aws_region
    ssm_password_param   = local.ssm_param
    airflow_image_digest = var.airflow_image_digest
  })

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    # Hop 2: containers Docker precisam do IMDS da instance role (hop 1 fica só no host).
    http_put_response_hop_limit = 2
  }

  tags = {
    Name       = "${var.name_prefix}airflow-ec2"
    CostCenter = "lab"
  }

  # Avoid replace when Amazon publishes a newer AL2023 AMI.
  lifecycle {
    ignore_changes = [ami]
  }

  depends_on = [aws_s3_object.compose_package]
}

resource "aws_cloudwatch_metric_alarm" "status_check_failed" {
  alarm_name          = "${var.name_prefix}airflow-ec2-status-check"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Maximum"
  threshold           = 1
  treat_missing_data  = "notBreaching"

  dimensions = {
    InstanceId = aws_instance.airflow.id
  }

  tags = {
    Name       = "${var.name_prefix}airflow-ec2-status-check"
    CostCenter = "lab"
  }
}

output "instance_id" {
  value = aws_instance.airflow.id
}

output "public_ip" {
  value = aws_instance.airflow.public_ip
}

output "ui_url" {
  value = "http://${aws_instance.airflow.public_ip}:8080"
}

output "security_group_id" {
  value = aws_security_group.airflow_ec2.id
}

output "ssm_password_parameter_name" {
  value = local.ssm_param
}
