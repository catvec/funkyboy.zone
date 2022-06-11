# Kubernetes
Manifests for the Kubernetes cluster.

# Table Of Contents
- [Overview](#overview)
- [Instructions](#instructions)
- [Planning](#planning)

# Overview
Once the Kubernetes cluster has been provisioned by [Terraform](../terraform) the manifests in this directory are applied to the cluster using Kustomize and Kubectl.

Provides the following services:

- [Operator Lifecycle Manager](./base/operator-lifecycle-manager)
- [ArgoCD](./base/argocd)

# Instructions
The manifests in this directory include custom resource definitions. Once these are applied to the Kubernetes cluster it may take a few moments for their api version's and kind's to be recognized as valid. As a result some manifests in this directory will likely be rejected by the Kubernetes cluster on the first attempt. Therefore one must apply these manifests once, wait a few seconds, and then apply them again.

# Planning
## Standard Labels
All applications in the cluster should have the following labels:

- `app`: Logical name of an application

## Future Services
### Teleport
Initially [Teleport](https://goteleport.com) was going to be used for user authentication and private cluster access. However the Teleport program does not allow for declarative setup, as setup must be done manually via a CLI. Potential future plans:

- Code an operator to manage Teleport
- Maybe use an alternative tool like the Ory stack
- [This Wireguard operator](https://github.com/jodevsa/wireguard-operator) could be a good lightweight alternative
- ArgoCD job that runs the [Teleport Terraform provider](https://goteleport.com/docs/setup/guides/terraform-provider/)
