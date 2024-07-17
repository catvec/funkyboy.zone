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
    - [Nginx Ingress](./base/nginx-ingress/)
    - [Cert Manager](./base/cert-manager/)
    - [Operator Lifecycle Manager](./base/operator-lifecycle-manager)
- [Gotify](./base/gotify/)
- [ChatGPT3 Discord Bot](./base/chatgpt-discord-bot/)
- [Rook Ceph](./base/rook/)
- [Emby](./base/media-server/)

# Instructions
1. Follow setup instructions in:
    - [`base/cert-manager/README.md`](./base/cert-manager/README.md#instructions)
    - [`base/chatgpt-discord-bot/README.md`](./base/chatgpt-discord-bot/README.md#instructions)
    - [`base/media-server/README.md`](./base/media-server/README.md#instructions)
    - [`base/kimai/README.md`](./base/kimai/README.md#instructions)
    - [`base/k8s-csi-s3/README.md`](./base/k8s-csi-s3/README.md#instructions)
    - [`base/discord-azure-boot/README.md`](./base/discord-azure-boot/README.md#instructions)
    - [`base/netbox/README.md`](./base/netbox/README.md#setup)
2. Run the `setup-k8s.py` script from the root of the repository:
   ```
   ./clients-scripts/setup-k8s.py
   ```

# Planning
## Standard Labels
All applications in the cluster should have the following labels:

- `project`: Name of overarching service which may be made up of several parts but works towards providing a unified experience of some sort
- `component`: Name of specific service

## Works In Progress
Hosting new services on Kubernetes can be easier than other platforms from a technology perspective. However much planning and thought must go into what is hosted and how. In general being careful and slow when adding service is the best practice. As to not put the cluster in a bad state. 

### WIP Services
Services where manifests are the the process of being written, but deployments aren't logistically planned out yet:

- [ArgoCD](./base/argocd) (WIP)
- [TektonCD](./base/tektoncd) (WIP)
- [Quay](./base/quay) (WIP)
- [Minio](./base/minio/)

### CI Deployment
TektonCD pipelines will trigger on repository pushes. The [TektonCD buildah task](https://hub.tekton.dev/tekton/task/buildah) can be used to build Docker images. The [TektonCD ArgoCD task](https://hub.tekton.dev/tekton/task/argocd-task-sync-and-wait) can be used to deploy resources to the cluster.