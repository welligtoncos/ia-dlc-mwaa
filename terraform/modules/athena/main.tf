# modules/athena — workgroup com enforce → results bucket (U2).

variable "name_prefix" {
  type = string
}

variable "workgroup_name" {
  type        = string
  description = "Nome do Athena workgroup."
}

variable "athena_results_bucket_name" {
  type = string
}

variable "bytes_scanned_cutoff_per_query" {
  type        = number
  description = "Cutoff de bytes scaneados por query (cost guardrail PoC)."
  default     = 10737418240 # 10 GiB
}

resource "aws_athena_workgroup" "this" {
  name = var.workgroup_name

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true
    bytes_scanned_cutoff_per_query     = var.bytes_scanned_cutoff_per_query

    result_configuration {
      output_location = "s3://${var.athena_results_bucket_name}/query-results/"

      encryption_configuration {
        encryption_option = "SSE_S3"
      }
    }
  }

  tags = {
    Name = var.workgroup_name
  }
}

output "workgroup_name" {
  value = aws_athena_workgroup.this.name
}

output "workgroup_arn" {
  value = aws_athena_workgroup.this.arn
}
