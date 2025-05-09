variable "aai_deployment_env" {
  description = "Deployment environment: dev, qa, or prod"
  type        = string
}

variable "aai_deployment_region" {
  description = "Deployment region: we run at the moment only on us-west-2"
  type        = string
}

variable "aai_s3_cert_bucket_name" {

  description = "s3 bucket name for certificates"
  type        = string
  sensitive   = true
}
