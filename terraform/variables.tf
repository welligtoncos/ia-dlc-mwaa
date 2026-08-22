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
