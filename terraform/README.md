# Terraform
Configuration as code for cloud resources.

# Table Of Contents
- [Overview](#overview)

# Overview
Terraform resources.

Currently in the middle of a refactor, in which all resources will be provisioned as an instance of a module. The reason is so a copy of the infrastructure could easily be spun up, without making a fork of this repository (ex., staging, production).

The `main.tf` file is an entrypoint, which makes an instance of the main `all-cloud` module. Terraform modules are located in [`modules/`](./modules).

Some files still remain which have not been migrated, they are numerically prefixed as such:

- `0000-0099`: Initialization
- `0100-0199`: Networking
- `0200-0299`: Compute
- `0300-0399`: Storage
- `0400-0499`: Websites

