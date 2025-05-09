variable "private_s3_bucket_name" {
  description = "Private S3 bucket name"
  type = string
}

variable "enable_versioning" {
  description = "Enables S3 bucket versioning if true"
  type = bool
}
