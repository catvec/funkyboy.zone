# Variables
variable "aws_access_key" {
  type = "string"
  description = "AWS API access key"
}

variable "aws_secret_key" {
  type = "string"
  description = "AWS API secret access key"
}

variable "aws_region" {
  type = "string"
  description = "AWS region"
  default = "us-east-1"
}

# Setup provider
provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "${var.aws_region}"
}
