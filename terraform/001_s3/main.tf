locals {
  bucket_name       = "abk-aai-awesome-bucket"
  deployment_region = "us-west-2"
}

provider "aws" {
  region = local.deployment_region
}

resource "aws_s3_bucket" "abkS3Demo" {
  bucket = local.bucket_name
}

resource "aws_s3_bucket_public_access_block" "abkS3DemoPrivate" {
  bucket = aws_s3_bucket.abkS3Demo.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = false
}
