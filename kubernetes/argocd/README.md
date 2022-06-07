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
