# Client Scripts
Scripts to run on a developers machine.

# Table Of Contents
- [Setup Kubernetes](#setup-kubernetes)

# Setup Kubernetes
Script to setup Kubernetes resources.

- [Overview](#setup-k8s-overview)
- [Usage](#setup-k8s-usage)

## Setup K8s - Overview
Uses Kustomize to assemble Kubernetes manifests and kubectl to apply them.

Different services are configured separately as "components". A component specification file defines where the component manifest files reside and how to apply them. 

This tool was created for two reasons: 

1. Large manifest files (Like those of CRDs in a large operator) can not be handled by the `kubectl apply` command, custom diff logic must be written
2. Breaking service manifests into different components makes applying changes less risky as the scope is limited

## Setup K8s - Usage
Create a component specification YAML file in the format of the `ComponentsSpec` class in [`main.py`](./main.py). By default the tool looks at `<repo root>/kubernetes/components.yaml` for this file. Change it with the `--components-spec` option.

To only apply one component use the `--only-component-path` (or `-o`) option with a path to the component's directory.