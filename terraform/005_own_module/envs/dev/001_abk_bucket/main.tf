locals {
  common_tags = {
    env = "${var.aai_deployment_env}"
  }
}

provider "aws" {
  region = var.aai_deployment_region
}


module "aai_s3_cert_bucket_module" {
  source                 = "../../../templates/s3-private-bucket"
  private_s3_bucket_name = var.aai_s3_cert_bucket_name
  enable_versioning      = true
}
