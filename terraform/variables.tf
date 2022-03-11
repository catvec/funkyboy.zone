variable "do_token" {
  type = string
  description = "Digital Ocean API token."
}

variable "aws_region" {
  type = string
  description = "AWS region."
  default = "us-east-1"
}
