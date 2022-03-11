# Terraform
Configuration as code for cloud resources.

# Table Of Contents
- [Overview](#overview)

# Overview
Terraform resources.

Currently in the middle of a refactor, in which all resources will be provisioned as an instance of a module. The reason is so a copy of the infrastructure could easily be spun up, without making a fork of this repository (ex., staging, production).

The `main.tf` file is an entrypoint, which makes an instance of the main `all-cloud` module. Terraform modules are located in [`modules/`](./modules).

Some files still remain which have not been migrated.

