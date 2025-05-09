# -----------------------------------------------------------------------------
# Private S3 bucket module
# -----------------------------------------------------------------------------
resource "aws_s3_bucket" "aaiPrivateS3Bucket" {
  bucket = var.private_s3_bucket_name

  object_lock_enabled = true
}

resource "aws_s3_bucket_versioning" "aaiPrivateS3BucketVersioning" {
  bucket = aws_s3_bucket.aaiPrivateS3Bucket.id
  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Disabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "aaiPrivateS3BucketEncryption" {
  bucket = aws_s3_bucket.aaiPrivateS3Bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}

resource "aws_s3_bucket_acl" "aaiPrivateS3BucketAcl" {
  bucket = aws_s3_bucket.aaiPrivateS3Bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "aaiPrivateS3BucketPrivate" {
  bucket = aws_s3_bucket.aaiPrivateS3Bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
