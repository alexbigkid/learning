locals {
  ec2_type          = "t2.nano"
  deployment_region = "us-west-2"
}

provider "aws" {
  region = local.deployment_region
}

resource "aws_instance" "example" {
  ami               = "ami-005bdb005fb00e791"
#   ami               = data.aws_ami.windows.id
  instance_type     = local.ec2_type

  lifecycle {
    ignore_changes = [ami]
  }

  tags = {
    Name = "abk-EC2"
  }
}
