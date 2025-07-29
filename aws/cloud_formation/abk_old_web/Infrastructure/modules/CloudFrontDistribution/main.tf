# -------------------------------------------S3 Bucket----------------------------------------------
resource "aws_s3_bucket" "siteHostingBucket" {
    bucket = "${var.s3_bucket_name}"
    acl    = "private"

    website {
        index_document = "index.html"
        error_document = "index.html"
    }

    cors_rule {
        allowed_headers = ["Authorization", "Content-Length"]
        allowed_methods = ["GET"]
        allowed_origins = ["*"]
        max_age_seconds = 3000
    }
}

resource "aws_s3_bucket" "dunkelHostingBucket" {
    bucket = "dunkel${s3_subdomain_ext}.${var.s3_bucket_name}"
}

resource "aws_s3_bucket" "photoHostingBucket" {
    bucket = "photo${s3_subdomain_ext}.${var.s3_bucket_name}"
}

resource "aws_s3_bucket" "smarthomeHostingBucket" {
    bucket = "smarthome${s3_subdomain_ext}.${var.s3_bucket_name}"
}

resource "aws_s3_bucket" "wwwHostingBucket" {
    bucket = "www${s3_subdomain_ext}.${var.s3_bucket_name}"
}


resource "aws_s3_bucket_public_access_block" "block_public_access" {
    bucket = aws_s3_bucket.siteHostingBucket.id

    block_public_acls       = true
    ignore_public_acls      = true
    block_public_policy     = true
    restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "allow_getObject" {
    bucket = aws_s3_bucket.siteHostingBucket.id
    policy = <<POLICY
{
    "Version": "2012-10-17",
    "Id": "MyPolicy",
    "Statement": [
        {
            "Sid": "APIReadForGetBucketObjects",
            "Effect": "Allow",
            "Principal": {
                "AWS": "${aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn}"
            },
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::${var.s3_bucket_name}/*"
        }
    ]
}
POLICY
}







# --------------------------------------------CloudFront------------------------------------
resource "aws_cloudfront_distribution" "s3_distribution" {
    origin {
        domain_name = aws_s3_bucket.siteHostingBucket.bucket_domain_name
        origin_id   = aws_s3_bucket.siteHostingBucket.id

        s3_origin_config {
        origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
        }
    }

    enabled             = true
    is_ipv6_enabled     = true
    default_root_object = "index.html"
    aliases = ["${var.website_domain_name}"]


    default_cache_behavior {
        allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
        cached_methods   = ["GET", "HEAD"]
        target_origin_id = aws_s3_bucket.siteHostingBucket.id

        forwarded_values {
        query_string = false

        cookies {
            forward = "none"
        }
        }

        viewer_protocol_policy = "redirect-to-https"
        min_ttl                = 0
        default_ttl            = 0
        max_ttl                = 0
        compress               = true
    }

    price_class = "PriceClass_100"

    restrictions {
        geo_restriction {
        restriction_type = "none"
        }
    }

    tags = {
        Environment = "production"
    }

    viewer_certificate {
        acm_certificate_arn = 	var.acm_certificate_arn
        minimum_protocol_version = "TLSv1"
        ssl_support_method       = "sni-only"
    }
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
    comment = "Origin Access Identity Personal Website"
}











# ------------------------------------Route 53----------------------------------
data "aws_route53_zone" "zone" {
    name         = "${var.website_domain_name}."
    private_zone = false
}

resource "aws_route53_record" "route53_alias_record" {
    depends_on = [
        "aws_cloudfront_distribution.s3_distribution",
    ]

    zone_id = "${data.aws_route53_zone.zone.zone_id}"
    name    = "${var.website_domain_name}"
    type    = "A"
    //type A is a IPV4 record

    alias {
        name    = aws_cloudfront_distribution.s3_distribution.domain_name
        zone_id = "Z2FDTNDATAQYW2"
        //This zone ID is identical for all cloudfront distributions. It is just this hardcoded string.

        evaluate_target_health = false
    }
}
