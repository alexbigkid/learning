locals {
  ddb_name          = "abk-aai-awesome-ddb"
  deployment_region = "us-west-2"
}

provider "aws" {
  region = local.deployment_region
}


resource "aws_dynamodb_table" "aaiDynamodbTerraformLock" {
  name           = local.ddb_name
  hash_key       = "userId"
  range_key      = "email"
  read_capacity  = 20
  write_capacity = 20
  #   billing_mode = "PAY_PER_REQUEST"
  billing_mode = "PROVISIONED"

  attribute {
    name = "userId"
    type = "S"
  }

  attribute {
    name = "email"
    type = "S"
  }

  ttl {
    attribute_name = "TimeToExist"
    enabled        = false
  }

  tags = {
    env = "dev"
  }
}
