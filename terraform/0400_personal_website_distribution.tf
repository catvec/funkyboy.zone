# SSL Certificate
resource "aws_acm_certificate" "personal_website" {
  domain_name = aws_route53_zone.domain_4e48_dev.name
  
  subject_alternative_names = [
    "www.${aws_route53_zone.domain_4e48_dev.name}",
    aws_route53_zone.noahh_io.name,
    "www.${aws_route53_zone.noahh_io.name}",
    aws_route53_zone.noahhuppert_com.name,
    "www.${aws_route53_zone.noahhuppert_com.name}"
  ]
  
  validation_method = "DNS"

  tags = {
    Name = "personal-website"
  }
}

resource "aws_route53_record" "record_4e48_dev_personal_website_acm_proof" {
  zone_id = aws_route53_zone.domain_4e48_dev.id
  name = tolist(aws_acm_certificate.personal_website.domain_validation_options).0.resource_record_name
  type = tolist(aws_acm_certificate.personal_website.domain_validation_options).0.resource_record_type
  records = [
    tolist(aws_acm_certificate.personal_website.domain_validation_options).0.resource_record_value
  ]
  ttl = "60"
}

resource "aws_route53_record" "noahh_io_personal_website_acm_proof" {
  zone_id = aws_route53_zone.noahh_io.id
  name = tolist(aws_acm_certificate.personal_website.domain_validation_options).1.resource_record_name
  type = tolist(aws_acm_certificate.personal_website.domain_validation_options).1.resource_record_type
  records = [
    tolist(aws_acm_certificate.personal_website.domain_validation_options).1.resource_record_value
  ]
  ttl = "60"
}

resource "aws_route53_record" "noahhuppert_com_personal_website_acm_proof" {
  zone_id = aws_route53_zone.noahhuppert_com.id
  name = tolist(aws_acm_certificate.personal_website.domain_validation_options).2.resource_record_name
  type = tolist(aws_acm_certificate.personal_website.domain_validation_options).2.resource_record_type
  records = [
    tolist(aws_acm_certificate.personal_website.domain_validation_options).2.resource_record_value
  ]
  ttl = "60"
}

# Distribution
variable "personal_website_content_bucket_prefix" {
  type = string
  description = "Prefix in content bucket to serve files for my personal website"
  default = "/NoahHuppert.com"
}

resource "aws_cloudfront_distribution" "personal_website" {
  origin {
    domain_name = aws_s3_bucket.web_content.bucket_regional_domain_name
    origin_id = aws_s3_bucket.web_content.bucket
    origin_path = var.personal_website_content_bucket_prefix
  }

  enabled = true
  is_ipv6_enabled = true
  default_root_object = "index.html"

  aliases = [
    var.domain_4e48_dev_name,
    var.domain_noahh_io_name,
    var.domain_noahhuppert_com_name,
  ]

  default_cache_behavior {
    allowed_methods = [ "HEAD", "OPTIONS", "GET" ]
    cached_methods = [ "HEAD", "GET" ]

    target_origin_id = aws_s3_bucket.web_content.bucket

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
    acm_certificate_arn = aws_acm_certificate.personal_website.arn
    ssl_support_method = "sni-only"
  }
}
