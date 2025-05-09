module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "abk-aai-team-is-awesome"
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
