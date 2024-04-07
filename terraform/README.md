# Terraform
Configuration as code for cloud resources.

# Table Of Contents
- [Overview](#overview)

# Overview
Terraform resources. Split into two projects:

- [`compute/`](./compute/): Underlying resources to run services
- [`domains/`](./domains/): Networking resources to route traffic to services

Domains resources depend on compute resources being created.