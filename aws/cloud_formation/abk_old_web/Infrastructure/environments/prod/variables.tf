variable "aws_region" {
    default = "us-west-1"
}

variable "website_domain_name" {
    default = "abkcompany.com"
}

variable "s3_bucket_name" {
    default = "${var.website_domain_name}"
}

variable "env" {
    default = "prod"
}

variable "s3_subdomain_ext" {
    default = ""
}
