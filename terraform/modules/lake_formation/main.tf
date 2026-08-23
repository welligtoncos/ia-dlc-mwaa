# modules/lake_formation — register location, LF-Tags, grants (U2).
# PREREQ: conta deve ter Data Lake administrator configurado MANUALMENTE.
# Este módulo NÃO chama aws_lakeformation_data_lake_settings (evita sobrescrever admins).

variable "name_prefix" {
  type = string
}

variable "data_bucket_arn" {
  type = string
}

variable "glue_database_name" {
  type = string
}

variable "glue_role_arn" {
  type = string
}

variable "mwaa_execution_role_arn" {
  type = string
}

variable "project_tag_value" {
  type    = string
  default = "ia-dlc-mwaa"
}

# Registra o bucket de dados no Lake Formation.
resource "aws_lakeformation_resource" "data" {
  arn = var.data_bucket_arn
}

# LF-Tags — Classification + Project (NFR / FD).
resource "aws_lakeformation_lf_tag" "classification" {
  key    = "Classification"
  values = ["raw", "processed"]
}

resource "aws_lakeformation_lf_tag" "project" {
  key    = "Project"
  values = [var.project_tag_value]
}

# Associa tags ao database do Glue.
resource "aws_lakeformation_resource_lf_tags" "database" {
  database {
    name = var.glue_database_name
  }

  lf_tag {
    key   = aws_lakeformation_lf_tag.project.key
    value = var.project_tag_value
  }

  depends_on = [aws_lakeformation_lf_tag.project]
}

# Glue crawler role — DATA_LOCATION_ACCESS + database describe/create table.
resource "aws_lakeformation_permissions" "glue_location" {
  principal   = var.glue_role_arn
  permissions = ["DATA_LOCATION_ACCESS"]

  data_location {
    arn = aws_lakeformation_resource.data.arn
  }
}

resource "aws_lakeformation_permissions" "glue_database" {
  principal   = var.glue_role_arn
  permissions = ["CREATE_TABLE", "ALTER", "DESCRIBE"]

  database {
    name = var.glue_database_name
  }
}

# MWAA execution role — prepare U4 (catalog + location read).
resource "aws_lakeformation_permissions" "mwaa_location" {
  principal   = var.mwaa_execution_role_arn
  permissions = ["DATA_LOCATION_ACCESS"]

  data_location {
    arn = aws_lakeformation_resource.data.arn
  }
}

resource "aws_lakeformation_permissions" "mwaa_database" {
  principal                     = var.mwaa_execution_role_arn
  permissions                   = ["DESCRIBE"]
  permissions_with_grant_option = []

  database {
    name = var.glue_database_name
  }
}

# Tag-based grant example: Project tag DESCRIBE for MWAA (demonstrável).
resource "aws_lakeformation_permissions" "mwaa_lf_tag_project" {
  principal   = var.mwaa_execution_role_arn
  permissions = ["DESCRIBE"]

  lf_tag_policy {
    resource_type = "DATABASE"

    expression {
      key    = aws_lakeformation_lf_tag.project.key
      values = [var.project_tag_value]
    }
  }
}

output "lf_tag_classification_key" {
  value = aws_lakeformation_lf_tag.classification.key
}

output "lf_tag_project_key" {
  value = aws_lakeformation_lf_tag.project.key
}

output "data_lake_resource_arn" {
  value = aws_lakeformation_resource.data.arn
}
