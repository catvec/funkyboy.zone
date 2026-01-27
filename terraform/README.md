# Terraform
Configuration as code for cloud resources.

# Table Of Contents
- [Overview](#overview)
- [Configuration](#configuration)

# Overview
Terraform resources. Split into two projects:

- [`compute/`](./compute/): Underlying resources to run services
- [`domains/`](./domains/): Networking resources to route traffic to services

Domains resources depend on compute resources being created.

# Configuration
Required environment variables (set in `.env` file at repo root):

| Variable | Description |
|----------|-------------|
| `DO_API_TOKEN` | DigitalOcean API token |
| `SPACES_ACCESS_ID` | DigitalOcean Spaces access key ID |
| `SPACES_SECRET_KEY` | DigitalOcean Spaces secret key |

## Setting up credentials

1. **DigitalOcean API Token**: Create at [DO Console > API > Tokens](https://cloud.digitalocean.com/account/api/tokens)

2. **Spaces Keys**: Create at [DO Console > API > Spaces Keys](https://cloud.digitalocean.com/account/api/spaces). This generates both `SPACES_ACCESS_ID` and `SPACES_SECRET_KEY`.