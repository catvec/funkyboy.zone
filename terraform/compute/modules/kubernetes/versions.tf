terraform {
  required_providers {
    digitalocean = {
	 source = "digitalocean/digitalocean"
	 version = "2.43.0"
    }

    local = {
      source = "hashicorp/local"
      version = "2.5.2"
    }
  }
  
  required_version = ">= 0.13"
}
