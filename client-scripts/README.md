# Client Scripts
Scripts to run on a developers machine.

# Table Of Contents
- [Overview](#overview)
- [Setup Cloud](#setup-cloud)
- [Setup Kubernetes](#setup-kubernetes)

# Overview
Scripts to provision and manage cloud infrastructure.

- [`setup-cloud.sh`](./setup-cloud.sh): Provision cloud resources
- [`setup-k8s.sh`](./setup-k8s.sh): Configure Kubernetes manifests

# Setup Cloud
Script to run Terraform.

- [Overview](#setup-cloud--overview)
- [Usage](#setup-cloud---usage)

## Setup Cloud - Overview
Runs Terraform plan and apply to provision cloud resources.

Different pieces of infrastructure are split into different Terraform "projects". A projects specification file defines where the projects are located and where each project's state is stored.

## Setup Cloud - Usage
Create a projects specification YAML file in the format of the `ProjectsListSpec` class in the [`setup_cloud.py`](./client_scripts/setup_cloud.py) file. By default this tool looks for the projects specification file in `<repo root>/terraform/projects.yaml`. Change this with the `--projects-spec-path` option.

To only apply one project provide the `--only-project` (`-o`) option with the path of the project.

# Setup Kubernetes
Script to setup Kubernetes resources.

- [Overview](#setup-k8s--overview)
- [Usage](#setup-k8s---usage)

## Setup K8s - Overview
Uses Kustomize to assemble Kubernetes manifests and kubectl to apply them.

Different services are configured separately as "components". A component specification file defines where the component manifest files reside and how to apply them. 

This tool was created for two reasons: 

1. Large manifest files (Like those of CRDs in a large operator) can not be handled by the `kubectl apply` command, custom diff logic must be written
2. Breaking service manifests into different components makes applying changes less risky as the scope is limited

## Setup K8s - Usage
Create a component specification YAML file in the format of the `ComponentsSpec` class in [`setup_k8s.py`](./client_scripts/setup_k8s.py). By default the tool looks at `<repo root>/kubernetes/components.yaml` for this file. Change it with the `--components-spec` option.

To only apply one component use the `--only-component-path` (or `-o`) option with a path to the component's directory.