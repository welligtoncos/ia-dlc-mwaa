variable "name_prefix" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "environment" {
  type = string
}

variable "project_name" {
  type = string
}

variable "artifact_bucket_name" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "operator_cidr" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "instance_profile_name" {
  type = string
}

variable "airflow_image_digest" {
  type        = string
  description = "amd64 digest pin for apache/airflow:2.11.2"
}

variable "ssm_password_parameter_name" {
  type = string
}
