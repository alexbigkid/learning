output "aaiPrivateS3BucketId" {
  description = "Private S3 Bucket ID"
  value       = aws_s3_bucket.aaiPrivateS3Bucket.id
  sensitive   = true
}
