resource "aws_s3_bucket" "web-content" {
  bucket = "noahh-web-content"
  acl = "public-read"
}
