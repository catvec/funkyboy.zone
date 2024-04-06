# Terraform
Configuration as code for cloud resources.

# Table Of Contents
- [Overview](#overview)

# Overview
Terraform resources.

The `main.tf` file is an entrypoint, which makes an instance of the main `all-cloud` module. Terraform modules are located in [`modules/`](./modules).

Once cloud resources have been provisioned the Kubernetes cluster will be setup by the Terraform in the [`kubernetes-terraform`](./kubernetes-terraform) directory. This is a separate Terraform project, which requires this Terraform project's resources to operate.
