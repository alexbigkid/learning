# -----------------------------------------------------------------------------
# definitions and Terraform backend
# -----------------------------------------------------------------------------
locals {
  common_tags = {
    env = "dev"
  }
}

provider "aws" {
  region = "us-west-2"
}

terraform {
  backend "s3" {
    bucket = "aai-terraform-state-do-not-delete-dev"
    key    = "dev/terraform-demo/terraform.tfstate"
    region = "us-west-2"

    dynamodb_table = "aai-terraform-lock"
    encrypt        = true
  }
}


# -----------------------------------------------------------------------------
# using AWS predefined module
# -----------------------------------------------------------------------------
module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "abk-eric-wants-different-name"
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    enabled = true
  }

  tags = {
    purpose = "demo"
    env     = "dev"
  }
}
