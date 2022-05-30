# Kubernetes Terraform
Terraform project which will setup the Kubernetes cluster.

# Table Of Contents
- [Overview](#overview)

# Overview
The main Terraform project (in the parent directory) creates a Kubernetes cluster. Once that cluster has been created this Terraform project then configures the cluster. This project is required to be a separate project because the Kubernetes Terraform provider is being used, and providers cannot reference resource attributes.
