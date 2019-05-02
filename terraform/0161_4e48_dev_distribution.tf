# SSL Certificate
resource "aws_acm_certificate" "4e48-dev" {
  domain_name = "${aws_route53_zone.4e48-dev.name}"
  validation_method = "DNS"
}

resource "aws_route53_record" "4e48-dev-acm-proof" {
  zone_id = "${aws_route53_zone.4e48-dev.id}"
  name = "${aws_acm_certificate.4e48-dev.domain_validation_options.0.resource_record_name}"
  type = "${aws_acm_certificate.4e48-dev.domain_validation_options.0.resource_record_type}"
  records = [
    "${aws_acm_certificate.4e48-dev.domain_validation_options.0.resource_record_value}" 
  ]
  ttl = "60"
}

# Distribution
variable "4e48_dev_content_bucket_prefix" {
  type = "string"
  description = "Prefix in content bucket to serve files for 4e48.dev"
  default = "/NoahHuppert.com"
}

resource "aws_cloudfront_distribution" "4e48-dev" {
  origin {
    domain_name = "${aws_s3_bucket.web-content.bucket_regional_domain_name}"
    origin_id = "${aws_s3_bucket.web-content.bucket}"
    origin_path = "${var.4e48_dev_content_bucket_prefix}"
  }

  enabled = true
  is_ipv6_enabled = true
  default_root_object = "index.html"

  aliases = [
    "4e48.dev"
  ]

  default_cache_behavior {
    allowed_methods = [ "HEAD", "OPTIONS", "GET" ]
    cached_methods = [ "HEAD", "GET" ]

    target_origin_id = "${aws_s3_bucket.web-content.bucket}"

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 60
    max_ttl                = 3600

    forwarded_values {
      query_string = true
      
      cookies {
	forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = "${aws_acm_certificate.4e48-dev.arn}"
    ssl_support_method = "sni-only"
  }
}

resource "aws_route53_record" "4e48-dev-distribution" {
  zone_id = "${aws_route53_zone.4e48-dev.id}"
  name = "${aws_route53_zone.4e48-dev.name}"
  type = "A"

  alias {
    name = "${aws_cloudfront_distribution.4e48-dev.domain_name}"
    zone_id = "${aws_cloudfront_distribution.4e48-dev.hosted_zone_id}"
    evaluate_target_health = true
  }
}
