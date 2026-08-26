# outputs.tf
# Contrato compartilhado para U2–U4 (ver aidlc-docs/construction/shared-infrastructure.md).

output "name_prefix" {
  description = "Prefixo {project}-{env}-"
  value       = local.name_prefix
}

output "aws_region" {
  description = "Região efetiva"
  value       = var.aws_region
}

output "vpc_id" {
  description = "VPC compartilhada"
  value       = module.network.vpc_id
}

output "private_subnet_ids" {
  description = "Subnets privadas (MWAA / futuros tasks ECS)"
  value       = module.network.private_subnet_ids
}

output "public_subnet_id" {
  description = "Subnet pública (NAT)"
  value       = module.network.public_subnet_id
}

output "mwaa_security_group_id" {
  description = "Security group do MWAA"
  value       = module.network.mwaa_security_group_id
}

output "orchestrator_mode" {
  description = "Modo do orquestrador: ec2 ou mwaa"
  value       = var.orchestrator_mode
}

output "orchestrator_role_arn" {
  description = "Role IAM do orquestrador ativo (EC2 ou MWAA)"
  value       = local.orchestrator_role_arn
}

output "airflow_ec2_instance_id" {
  description = "Instance ID da EC2 Airflow (mode=ec2)"
  value       = var.orchestrator_mode == "ec2" ? module.airflow_ec2[0].instance_id : null
}

output "airflow_ec2_public_ip" {
  description = "IP público da EC2 Airflow (dinâmico; muda após stop/start)"
  value       = var.orchestrator_mode == "ec2" ? module.airflow_ec2[0].public_ip : null
}

output "airflow_ui_url" {
  description = "URL da UI Airflow na EC2 (mode=ec2)"
  value       = var.orchestrator_mode == "ec2" ? module.airflow_ec2[0].ui_url : null
}

output "airflow_ec2_role_arn" {
  description = "ARN da role EC2 Airflow (mode=ec2)"
  value       = var.orchestrator_mode == "ec2" ? module.airflow_ec2_identity[0].role_arn : null
}

output "airflow_ui_password_ssm_param" {
  description = "SSM Parameter com senha admin da UI (mode=ec2)"
  value       = var.orchestrator_mode == "ec2" ? local.airflow_ssm_password_param : null
}

output "artifact_bucket_name" {
  description = "Bucket de DAGs/plugins/requirements"
  value       = module.artifact_store.bucket_name
}

output "artifact_bucket_arn" {
  description = "ARN do bucket de artefatos"
  value       = module.artifact_store.bucket_arn
}

output "mwaa_environment_name" {
  description = "Nome do ambiente MWAA (mode=mwaa)"
  value       = var.orchestrator_mode == "mwaa" ? module.mwaa[0].environment_name : null
}

output "mwaa_environment_arn" {
  description = "ARN do ambiente MWAA (mode=mwaa)"
  value       = var.orchestrator_mode == "mwaa" ? module.mwaa[0].environment_arn : null
}

output "mwaa_webserver_url" {
  description = "URL da UI Airflow MWAA (mode=mwaa)"
  value       = var.orchestrator_mode == "mwaa" ? module.mwaa[0].webserver_url : null
}

output "mwaa_execution_role_arn" {
  description = "Execution role MWAA (mode=mwaa; use orchestrator_role_arn para contrato genérico)"
  value       = var.orchestrator_mode == "mwaa" ? module.identity[0].execution_role_arn : null
}

# --- U2 outputs (contrato shared) ---

output "data_lake_bucket_name" {
  description = "Bucket do data lake (raw/ + processed/)"
  value       = module.data_lake.data_bucket_name
}

output "data_lake_bucket_arn" {
  description = "ARN do bucket do data lake"
  value       = module.data_lake.data_bucket_arn
}

output "athena_results_bucket_name" {
  description = "Bucket de resultados Athena (lifecycle 7d)"
  value       = module.data_lake.athena_results_bucket_name
}

output "athena_results_bucket_arn" {
  description = "ARN do bucket de resultados Athena"
  value       = module.data_lake.athena_results_bucket_arn
}

output "glue_database_name" {
  description = "Glue Catalog database"
  value       = module.glue_catalog.database_name
}

output "raw_crawler_name" {
  description = "Crawler raw (on-demand)"
  value       = module.glue_catalog.raw_crawler_name
}

output "processed_crawler_name" {
  description = "Crawler processed (on-demand)"
  value       = module.glue_catalog.processed_crawler_name
}

output "glue_service_role_arn" {
  description = "IAM role dos crawlers Glue"
  value       = module.glue_catalog.glue_service_role_arn
}

output "athena_workgroup_name" {
  description = "Athena workgroup (enforce → results bucket)"
  value       = module.athena.workgroup_name
}

output "lf_tag_classification_key" {
  description = "LF-Tag Classification"
  value       = module.lake_formation.lf_tag_classification_key
}

output "lf_tag_project_key" {
  description = "LF-Tag Project"
  value       = module.lake_formation.lf_tag_project_key
}

# --- U3 outputs ---

output "lambda_function_name" {
  description = "Nome da Lambda marker"
  value       = module.lambda_executor.function_name
}

output "lambda_function_arn" {
  description = "ARN da Lambda marker"
  value       = module.lambda_executor.function_arn
}

output "glue_job_name" {
  description = "Nome do Glue Job passthrough"
  value       = module.glue_job.job_name
}

output "ecs_cluster_arn" {
  description = "ARN do cluster ECS"
  value       = module.ecs_executor.cluster_arn
}

output "ecs_cluster_name" {
  description = "Nome do cluster ECS"
  value       = module.ecs_executor.cluster_name
}

output "ecs_task_definition_arn" {
  description = "ARN da task definition Fargate marker"
  value       = module.ecs_executor.task_definition_arn
}

output "ecs_security_group_id" {
  description = "SG das tasks ECS U3"
  value       = module.ecs_executor.security_group_id
}

output "lambda_role_arn" {
  description = "IAM role da Lambda"
  value       = module.lambda_executor.role_arn
}

output "glue_job_role_arn" {
  description = "IAM role do Glue Job"
  value       = module.glue_job.role_arn
}

output "ecs_task_role_arn" {
  description = "IAM task role ECS"
  value       = module.ecs_executor.task_role_arn
}

output "ecs_execution_role_arn" {
  description = "IAM execution role ECS"
  value       = module.ecs_executor.execution_role_arn
}

# --- U4 outputs ---

output "sns_topic_arn" {
  description = "ARN do tópico SNS de status do DAG"
  value       = module.sns.topic_arn
}

output "sns_topic_name" {
  description = "Nome do tópico SNS de status do DAG"
  value       = module.sns.topic_name
}

output "airflow_variables_map" {
  description = "Mapa lab_* para scripts/set-airflow-variables (colar via SSM)"
  value = {
    lab_aws_region           = var.aws_region
    lab_lambda_function_name = module.lambda_executor.function_name
    lab_glue_job_name        = module.glue_job.job_name
    lab_ecs_cluster          = module.ecs_executor.cluster_name
    lab_ecs_task_definition  = module.ecs_executor.task_definition_arn
    lab_ecs_subnets          = join(",", module.network.private_subnet_ids)
    lab_ecs_security_groups  = module.ecs_executor.security_group_id
    lab_athena_workgroup     = module.athena.workgroup_name
    lab_glue_database        = module.glue_catalog.database_name
    lab_sns_topic_arn        = module.sns.topic_arn
    lab_athena_output_s3     = "s3://${module.data_lake.athena_results_bucket_name}/"
    lab_e2e_enable_select    = "false"
    lab_e2e_schedule         = ""
    lab_airflow_ui_base      = var.orchestrator_mode == "ec2" ? coalesce(module.airflow_ec2[0].ui_url, "") : ""
  }
}
