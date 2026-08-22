# modules/artifact_store — bucket dedicado a DAGs/plugins/requirements (não é o data lake).

variable "name_prefix" {
  type = string
}

variable "bucket_name" {
  type        = string
  description = "Nome globalmente único do bucket."
}

resource "aws_s3_bucket" "artifacts" {
  bucket = var.bucket_name

  tags = {
    Name = "${var.name_prefix}artifacts"
  }
}

# Versionamento — MWAA referencia object versions de requirements/plugins.
resource "aws_s3_bucket_versioning" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Block Public Access total — NFR-SEC / BR-ART.
resource "aws_s3_bucket_public_access_block" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# SSE-S3 — encryption at rest sem CMK (PoC).
resource "aws_s3_bucket_server_side_encryption_configuration" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Ownership controls — evita ACL legado.
resource "aws_s3_bucket_ownership_controls" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Bootstrap mínimo — MWAA exige objetos se paths plugins/requirements forem setados.
# Não é deploy de DAG de negócio (isso é scripts/sync-dags.sh / U4).

resource "aws_s3_object" "dags_keep" {
  bucket  = aws_s3_bucket.artifacts.id
  key     = "dags/.gitkeep"
  content = ""
}

resource "aws_s3_object" "plugins_keep" {
  bucket  = aws_s3_bucket.artifacts.id
  key     = "plugins/.gitkeep"
  content = ""
}

resource "aws_s3_object" "requirements" {
  bucket  = aws_s3_bucket.artifacts.id
  key     = "requirements.txt"
  content = "# Placeholder — add providers in U4\n"
}

output "bucket_name" {
  value = aws_s3_bucket.artifacts.id
}

output "bucket_arn" {
  value = aws_s3_bucket.artifacts.arn
}
