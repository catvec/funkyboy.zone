terraform {
  required_providers {
    aws = {
	 source = "hashicorp/aws"
	 version = "~> 3.22.0"
    }
    
    digitalocean = {
	 source = "digitalocean/digitalocean"
	 version = "~> 2.3.0"
    }
  }
  
  required_version = ">= 0.13"
}
