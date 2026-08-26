# variables.tf
# Nada hardcoded nos módulos — defaults sensatos para PoC dev.

variable "project_name" {
  type        = string
  description = "Nome curto do projeto usado no prefixo de recursos."
  default     = "ia-dlc-mwaa"
}

variable "environment" {
  type        = string
  description = "Ambiente lógico (ex.: dev)."
  default     = "dev"
}

variable "aws_region" {
  type        = string
  description = "Região AWS. Default us-east-1; sobrescreva se a conta usar outra."
  default     = "us-east-1"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR da VPC da fundação MWAA."
  default     = "10.10.0.0/16"
}

variable "public_subnet_cidr" {
  type        = string
  description = "CIDR da subnet pública (NAT)."
  default     = "10.10.0.0/24"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "CIDRs das duas subnets privadas (MWAA exige 2 AZs)."
  default     = ["10.10.1.0/24", "10.10.2.0/24"]
}

variable "airflow_version" {
  type        = string
  description = "Versão Airflow do MWAA. Override se 2.11.2 não estiver liberada na conta/região."
  default     = "2.11.2"
}

variable "environment_class" {
  type        = string
  description = "Classe do ambiente MWAA. Headroom futuro: mw1.medium (não default)."
  default     = "mw1.small"
}

variable "webserver_access_mode" {
  type        = string
  description = "API MWAA: PUBLIC_ONLY (PoC) ou PRIVATE_ONLY (exige VPN/bastion)."
  default     = "PUBLIC_ONLY"

  validation {
    condition     = contains(["PUBLIC_ONLY", "PRIVATE_ONLY"], var.webserver_access_mode)
    error_message = "webserver_access_mode must be PUBLIC_ONLY or PRIVATE_ONLY."
  }
}

variable "additional_tags" {
  type        = map(string)
  description = "Tags extras mescladas às tags padrão."
  default     = {}
}

variable "glue_database_name" {
  type        = string
  description = "Override opcional do Glue Database (default: {project}_{env}_lake)."
  default     = null
}

variable "athena_workgroup_name" {
  type        = string
  description = "Override opcional do Athena workgroup (default: {project}-{env}-dev)."
  default     = null
}

variable "lambda_memory_mb" {
  type        = number
  description = "Memória da Lambda marker (PoC). Headroom: aumentar via var."
  default     = 256
}

variable "glue_worker_type" {
  type        = string
  description = "Tipo de worker Glue. Default G.1X."
  default     = "G.1X"
}

variable "glue_number_of_workers" {
  type        = number
  description = "Número de workers Glue. Default 2 (PoC)."
  default     = 2
}

variable "ecs_cpu" {
  type        = string
  description = "CPU Fargate (unidades). Default 256."
  default     = "256"
}

variable "ecs_memory" {
  type        = string
  description = "Memória Fargate (MiB). Default 512."
  default     = "512"
}

variable "orchestrator_mode" {
  type        = string
  description = "Orquestrador: ec2 (default, Compose na EC2) ou mwaa (managed)."
  default     = "ec2"

  validation {
    condition     = contains(["ec2", "mwaa"], var.orchestrator_mode)
    error_message = "orchestrator_mode must be ec2 or mwaa."
  }
}

variable "operator_cidr" {
  type        = string
  description = "CIDR permitido na UI Airflow :8080 (mode=ec2). Restrinja ao seu IP/32 em lab compartilhado."
  default     = "0.0.0.0/0"

  validation {
    condition     = var.orchestrator_mode != "ec2" || can(cidrhost(var.operator_cidr, 0))
    error_message = "operator_cidr must be a valid CIDR when orchestrator_mode=ec2."
  }
}

variable "airflow_instance_type" {
  type        = string
  description = "Tipo da EC2 Airflow. Default t3.medium; contas Free Tier: use t3.small ou t3.micro."
  default     = "t3.medium"
}

variable "airflow_image_digest" {
  type        = string
  description = "Digest amd64 pinado para apache/airflow:2.11.2."
  default     = "sha256:a69d3b7e8013f57338ca19a0bc4de862f62af178a21088cd4459f1081911c07c"
}

variable "sns_notification_email" {
  type        = string
  description = "E-mail opcional para subscription SNS do status do DAG (vazio = só tópico)."
  default     = ""
}
