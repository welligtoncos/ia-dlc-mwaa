# modules/data_lake — buckets de dados + resultados Athena (U2).
# Controles: BPA, SSE-S3, deny HTTP, lifecycle 7d nos results.

variable "name_prefix" {
  type = string
}

variable "data_bucket_name" {
  type        = string
  description = "Nome globalmente único do bucket de dados."
}

variable "athena_results_bucket_name" {
  type        = string
  description = "Nome globalmente único do bucket de resultados Athena."
}

variable "athena_results_expiration_days" {
  type        = number
  description = "Dias até expirar objetos no bucket de resultados Athena."
  default     = 7
}

# ---------------------------------------------------------------------------
# Data lake bucket
# ---------------------------------------------------------------------------

resource "aws_s3_bucket" "data" {
  bucket = var.data_bucket_name

  tags = {
    Name = "${var.name_prefix}data"
  }
}

resource "aws_s3_bucket_versioning" "data" {
  bucket = aws_s3_bucket.data.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "data" {
  bucket = aws_s3_bucket.data.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "data" {
  bucket = aws_s3_bucket.data.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "data" {
  bucket = aws_s3_bucket.data.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Deny plaintext HTTP — NFR Design Q4=B.
data "aws_iam_policy_document" "data_tls_only" {
  statement {
    sid    = "DenyInsecureTransport"
    effect = "Deny"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.data.arn,
      "${aws_s3_bucket.data.arn}/*",
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "data" {
  bucket = aws_s3_bucket.data.id
  policy = data.aws_iam_policy_document.data_tls_only.json
}

# Prefixos lógicos — placeholders para crawlers (sem sample data via TF).
resource "aws_s3_object" "raw_keep" {
  bucket  = aws_s3_bucket.data.id
  key     = "raw/.gitkeep"
  content = ""
}

resource "aws_s3_object" "processed_keep" {
  bucket  = aws_s3_bucket.data.id
  key     = "processed/.gitkeep"
  content = ""
}

# ---------------------------------------------------------------------------
# Athena results bucket
# ---------------------------------------------------------------------------

resource "aws_s3_bucket" "athena_results" {
  bucket = var.athena_results_bucket_name

  tags = {
    Name = "${var.name_prefix}athena-results"
  }
}

resource "aws_s3_bucket_public_access_block" "athena_results" {
  bucket = aws_s3_bucket.athena_results.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "athena_results" {
  bucket = aws_s3_bucket.athena_results.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "athena_results" {
  bucket = aws_s3_bucket.athena_results.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "athena_results" {
  bucket = aws_s3_bucket.athena_results.id

  rule {
    id     = "expire-results"
    status = "Enabled"

    filter {}

    expiration {
      days = var.athena_results_expiration_days
    }
  }
}

data "aws_iam_policy_document" "athena_results_tls_only" {
  statement {
    sid    = "DenyInsecureTransport"
    effect = "Deny"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.athena_results.arn,
      "${aws_s3_bucket.athena_results.arn}/*",
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "athena_results" {
  bucket = aws_s3_bucket.athena_results.id
  policy = data.aws_iam_policy_document.athena_results_tls_only.json
}

output "data_bucket_name" {
  value = aws_s3_bucket.data.id
}

output "data_bucket_arn" {
  value = aws_s3_bucket.data.arn
}

output "athena_results_bucket_name" {
  value = aws_s3_bucket.athena_results.id
}

output "athena_results_bucket_arn" {
  value = aws_s3_bucket.athena_results.arn
}
