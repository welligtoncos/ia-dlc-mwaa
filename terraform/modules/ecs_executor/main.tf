# modules/ecs_executor — ECS Fargate task that writes a lake marker (U3). Sem Service.

variable "name_prefix" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "data_lake_bucket_name" {
  type = string
}

variable "data_lake_bucket_arn" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "cpu" {
  type    = string
  default = "256"
}

variable "memory" {
  type    = string
  default = "512"
}

variable "container_image" {
  type    = string
  default = "public.ecr.aws/aws-cli/aws-cli:latest"
}

data "aws_caller_identity" "current" {}

resource "aws_ecs_cluster" "this" {
  name = var.cluster_name

  setting {
    name  = "containerInsights"
    value = "disabled"
  }

  tags = {
    Name = var.cluster_name
  }
}

resource "aws_security_group" "ecs" {
  name        = "${var.name_prefix}ecs-marker"
  description = "U3 ECS Fargate task - egress only"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Egress for S3/API via NAT"
  }

  tags = {
    Name = "${var.name_prefix}ecs-marker"
  }
}

data "aws_iam_policy_document" "ecs_tasks_assume" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "execution" {
  name               = "${var.name_prefix}ecs-execution"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume.json

  tags = {
    Name = "${var.name_prefix}ecs-execution"
  }
}

resource "aws_iam_role_policy_attachment" "execution" {
  role       = aws_iam_role.execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "task" {
  name               = "${var.name_prefix}ecs-task"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume.json

  tags = {
    Name = "${var.name_prefix}ecs-task"
  }
}

data "aws_iam_policy_document" "task" {
  statement {
    sid    = "LakeMarkerWrite"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:ListBucket"
    ]
    resources = [
      var.data_lake_bucket_arn,
      "${var.data_lake_bucket_arn}/raw/*",
      "${var.data_lake_bucket_arn}/processed/*",
    ]
  }
}

resource "aws_iam_role_policy" "task" {
  name   = "${var.name_prefix}ecs-task"
  role   = aws_iam_role.task.id
  policy = data.aws_iam_policy_document.task.json
}

resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${var.name_prefix}marker"
  retention_in_days = 14
}

resource "aws_ecs_task_definition" "marker" {
  family                   = "${var.name_prefix}marker"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = aws_iam_role.execution.arn
  task_role_arn            = aws_iam_role.task.arn

  container_definitions = jsonencode([
    {
      name       = "marker"
      image      = var.container_image
      essential  = true
      entryPoint = ["/bin/sh", "-c"]
      command = [
        "DT=$(date -u +%F); echo \"source=ecs status=ok ts=$(date -u +%Y-%m-%dT%H:%M:%SZ)\" | aws s3 cp - \"s3://${var.data_lake_bucket_name}/raw/dt=$${DT}/ecs_marker.txt\""
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "marker"
        }
      }
    }
  ])

  tags = {
    Name = "${var.name_prefix}marker"
  }
}

output "cluster_name" {
  value = aws_ecs_cluster.this.name
}

output "cluster_arn" {
  value = aws_ecs_cluster.this.arn
}

output "task_definition_arn" {
  value = aws_ecs_task_definition.marker.arn
}

output "task_definition_family" {
  value = aws_ecs_task_definition.marker.family
}

output "security_group_id" {
  value = aws_security_group.ecs.id
}

output "execution_role_arn" {
  value = aws_iam_role.execution.arn
}

output "task_role_arn" {
  value = aws_iam_role.task.arn
}

output "subnet_ids" {
  value = var.private_subnet_ids
}
