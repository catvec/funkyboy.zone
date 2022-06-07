terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }

    remote = {
      source = "hashicorp/http"
      version = "2.1.0"
    }
  }
  
  required_version = ">= 0.13"
}
