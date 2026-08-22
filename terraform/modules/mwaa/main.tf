# modules/mwaa — ambiente Airflow gerenciado (US-02).

variable "name_prefix" {
  type = string
}

variable "environment_name" {
  type        = string
  description = "Nome do ambiente MWAA."
}

variable "airflow_version" {
  type = string
}

variable "environment_class" {
  type = string
}

variable "webserver_access_mode" {
  type = string
}

variable "source_bucket_arn" {
  type = string
}

variable "execution_role_arn" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
}

# Ambiente MWAA — create costuma levar 20–40+ minutos.
resource "aws_mwaa_environment" "this" {
  name              = var.environment_name
  airflow_version   = var.airflow_version
  environment_class = var.environment_class

  source_bucket_arn = var.source_bucket_arn
  dag_s3_path       = "dags"
  # plugins/requirements opcionais; paths padrão MWAA
  plugins_s3_path      = "plugins"
  requirements_s3_path = "requirements.txt"

  execution_role_arn    = var.execution_role_arn
  webserver_access_mode = var.webserver_access_mode
  max_workers           = 2
  min_workers           = 1

  network_configuration {
    security_group_ids = var.security_group_ids
    subnet_ids         = var.subnet_ids
  }

  # LoggingBaseline — logs nativos CloudWatch
  logging_configuration {
    dag_processing_logs {
      enabled   = true
      log_level = "INFO"
    }
    scheduler_logs {
      enabled   = true
      log_level = "INFO"
    }
    task_logs {
      enabled   = true
      log_level = "INFO"
    }
    webserver_logs {
      enabled   = true
      log_level = "INFO"
    }
    worker_logs {
      enabled   = true
      log_level = "INFO"
    }
  }

  tags = {
    Name = var.environment_name
  }

  # Evita churn quando objects requirements/plugins mudam fora do Terraform (sync).
  lifecycle {
    ignore_changes = [
      requirements_s3_object_version,
      plugins_s3_object_version,
    ]
  }
}

output "environment_name" {
  value = aws_mwaa_environment.this.name
}

output "environment_arn" {
  value = aws_mwaa_environment.this.arn
}

output "webserver_url" {
  value = aws_mwaa_environment.this.webserver_url
}
