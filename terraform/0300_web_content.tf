variable "web_content_bucket_name" {
  type = string
  description = "Name of web content bucket"
  default = "noahh-web-content"
}

resource "aws_s3_bucket" "web_content" {
  bucket = var.web_content_bucket_name
  acl = "public-read"
}

resource "aws_s3_bucket_policy" "web_content_read" {
  bucket = aws_s3_bucket.web_content.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "web-content-public-read",
  "Statement": [
        {
            "Sid": "AllowPublicAcces",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": [
                "arn:aws:s3:::${var.web_content_bucket_name}/*"
            ]
        }
  ]
}
POLICY
}
