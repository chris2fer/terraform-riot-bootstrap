

locals {
  bucket_name = var.s3_bucket_prefix != "" ? "${var.s3_bucket_prefix}-riot-tfg-ingest-${var.environment}" : "riot-tfg-ingest-${var.environment}"
}
resource "aws_s3_bucket" "b" {
  bucket = local.bucket_name

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = var.s3_bucket_kms_key_arn == "" ? aws_kms_key.mykey.arn : var.s3_bucket_kms_key_arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  tags = {
    Name        = local.bucket_name
    Environment = var.environment
  }
}

resource "aws_s3_bucket_public_access_block" "block_public_access" {
  bucket = aws_s3_bucket.b.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_kms_key" "mykey" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}