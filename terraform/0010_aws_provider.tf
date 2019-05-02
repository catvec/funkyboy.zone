# Variables
variable "aws_access_key_id" {
  type = "string"
  description = "AWS API access key ID"
}

variable "aws_secret_access_key" {
  type = "string"
  description = "AWS API secret access key"
}

variable "aws_default_region" {
  type = "string"
  description = "AWS region"
  default = "us-east-1"
}

# Setup provider
provider "aws" {
  access_key = "${var.aws_access_key_id}"
  secret_key = "${var.aws_secret_access_key}"
  region = "${var.aws_default_region}"
}
