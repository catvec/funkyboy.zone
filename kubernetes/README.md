# Kubernetes
Manifests for the Kubernetes cluster.

# Table Of Contents
- [Overview](#overview)
- [Instructions](#instructions)

# Overview
Once the Kubernetes cluster has been provisioned by [Terraform](../terraform) the manifests in this directory are applied to the cluster using Kustomize and Kubectl.

Provides the following services:

- [Operator Lifecycle Manager](./operator-lifecycle-manager)
- [ArgoCD](./argocd)

# Instructions
The manifests in this directory include custom resource definitions. Once these are applied to the Kubernetes cluster it may take a few moments for their api version's and kind's to be recognized as valid. As a result some manifests in this directory will likely be rejected by the Kubernetes cluster on the first attempt. Therefore one must apply these manifests once, wait a few seconds, and then apply them again.
