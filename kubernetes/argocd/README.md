# ArgoCD
The [ArgoCD Operator](https://argocd-operator.readthedocs.io/) and [ArgoCD cluster](https://argoproj.github.io/cd/).

# Table Of Contents
- [Overview](#overview)
- [Instructions](#instructions)

# Overview
Sets up an ArgoCD cluster:

- Installs the ArgoCD operator
- Defines an ArgoCD cluster to be run by the operator

# Instructions
## Retrieving Initial Admin Password
Once the cluster has been created the initial admin password will be stored in a secret. To retrieve it run:

```bash
./scripts/get-admin-password.sh
```

## Updating The ArgoCD Operator Subscription
The [`argocd-operator-subscription.yaml`](./argocd-operator-subscription.yaml) file is downloaded the Operator Hub website from: [`https://operatorhub.io/install/argocd-operator.yaml`](https://operatorhub.io/install/argocd-operator.yaml). This file is checked in to maintain consistency. To update it run:

```bash
./scripts/re-download-argocd-operator-subscription-manifest.sh
```

Then check in any changes.
