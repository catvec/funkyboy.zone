# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Development Commands

### Infrastructure Management
- **Setup cloud resources**: `./client-scripts/setup-cloud.sh`
- **Setup Kubernetes cluster**: `./client-scripts/setup-k8s.sh` 
- **Initialize server**: `./client-scripts/init.sh`
- **Apply RPI VPN Salt states**: Use Salt SSH with roster files in `lab/rpi-vpn/` directory

### Testing
- **Run RPI VPN tests**: `cd lab/rpi-vpn/test && ./scripts/run-tests.sh`
- **Vagrant testing environment**: `cd lab/rpi-vpn/test && vagrant up`

## Architecture Overview

This is a comprehensive infrastructure-as-code repository for managing the funkyboy.zone cloud resources and Kubernetes cluster. The system uses a multi-layered approach:

### Core Components

**Infrastructure as Code**
- `terraform/` - Two-tier Terraform setup:
  - `compute/` - Underlying cloud resources (DigitalOcean droplets, networking)
  - `domains/` - DNS and routing configuration
- State files stored in `secret/terraform/`

**Kubernetes Orchestration**
- `kubernetes/` - Kustomize-based Kubernetes manifests
- Foundational services: Nginx Ingress, Cert Manager, OLM
- Application services: Gotify, ChatGPT Discord Bot, Rook Ceph, Emby media server
- Uses component-based deployment strategy for controlled rollouts

**Client Automation**
- `client-scripts/` - Python-based automation tools
- `setup-cloud.py` - Multi-project Terraform orchestration
- `setup_k8s.py` - Component-based Kubernetes deployment with custom diff logic

**Lab Environment (RPI VPN)**
- `lab/rpi-vpn/` - Salt Stack configuration for Raspberry Pi VPN setup
- `lab/rpi-vpn/salt/` - Salt state files for RPI VPN configuration
- `lab/rpi-vpn/pillar/` - RPI VPN configuration data
- `lab/rpi-vpn/test/` - Vagrant-based testing environment with realistic VMs

### Key Directories

- `secret/` - Git-tracked encrypted secrets and sensitive configuration
- `lab/` - Experimental and testing infrastructure (primarily RPI VPN setup)
- `server-scripts/` - Scripts executed on target servers

### Service Architecture

The system hosts multiple services across different environments:
- **Kubernetes cluster**: Container orchestration for services like Gotify, ChatGPT Discord Bot, Emby media server, and various web applications
- **Lab environment**: Raspberry Pi VPN setup with comprehensive testing using Salt Stack

Key Kubernetes services include monitoring (Prometheus/Grafana), media server (Emby), chat bots, foundational services (Nginx Ingress, Cert Manager), and various web applications.

## Development Patterns

- Infrastructure changes follow a plan-apply pattern using Terraform
- Kubernetes deployments use component isolation for safer updates
- RPI VPN Salt states are tested using Vagrant VMs with full kernel support for accurate network/firewall testing
- Secrets are managed through encrypted configuration files
- Custom tooling handles large Kubernetes manifests that kubectl can't process

## Important Notes

- The repository includes both the funkyboy.zone-secrets submodule for sensitive data
- The main funkyboy.zone infrastructure has migrated from Salt Stack to Kubernetes
- Only the `lab/rpi-vpn/` Salt configuration remains active for the Raspberry Pi VPN lab environment
- RPI VPN testing uses realistic VMs rather than containers for accurate network/firewall validation