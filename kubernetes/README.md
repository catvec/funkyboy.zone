# Kubernetes
Manifests for the Kubernetes cluster.

# Table Of Contents
- [Overview](#overview)
- [Instructions](#instructions)
- [Planning](#planning)

# Overview
Once the Kubernetes cluster has been provisioned by [Terraform](../terraform) the manifests in this directory are applied to the cluster using Kustomize and Kubectl.

Provides the following services:

- Foundational services:
    - [Operator Lifecycle Manager](./base/operator-lifecycle-manager) (WIP)
    - [ArgoCD](./base/argocd) (WIP)
    - [TektonCD](./base/tektoncd) (WIP)
    - [Quay](./base/quay) (WIP)
    - [Cert Manager](./base/cert-manager/)
- [Gotify](./base/gotify/)

# Instructions
1. Follow setup instructions in:
    - [`base/cert-manager/README.md`](./base/cert-manager/README.md)
2. Run the `setup-k8s.py` script from the root of the repository:
   ```
   ./clients-scripts/setup-k8s.py
   ```

## Kubernetes Dashboard
To access the dashboard run the Kubernetes proxy (The `--address` option is not needed if not in the dev container):

```
kubectl proxy --address 0.0.0.0
```

Then access the Dashboard: [here](http://127.0.0.1:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/)

# Planning
## Standard Labels
All applications in the cluster should have the following labels:

- `project`: Name of overarching service which may be made up of several parts but works towards providing a unified experience of some sort
- `component`: Name of specific service

## CI Deployment
TektonCD pipelines will trigger on repository pushes. The [TektonCD buildah task](https://hub.tekton.dev/tekton/task/buildah) can be used to build Docker images. The [TektonCD ArgoCD task](https://hub.tekton.dev/tekton/task/argocd-task-sync-and-wait) can be used to deploy resources to the cluster.

## Future Services
### Teleport
Initially [Teleport](https://goteleport.com) was going to be used for user authentication and private cluster access. However the Teleport program does not allow for declarative setup, as setup must be done manually via a CLI. Potential future plans:

- Code an operator to manage Teleport
- Maybe use an alternative tool like the Ory stack
- [This Wireguard operator](https://github.com/jodevsa/wireguard-operator) could be a good lightweight alternative
- ArgoCD job that runs the [Teleport Terraform provider](https://goteleport.com/docs/setup/guides/terraform-provider/)
