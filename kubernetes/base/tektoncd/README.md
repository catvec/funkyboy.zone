# TektonCD
Installs the TektonCD operator.

# Table Of Contents
- [Overview](#overview)
- [Instructions](#instructions)

# Overview
The TektonCD program can run continuous integration pipelines in the Kubernetes cluster.

# Instructions
## Updating TektonCD Operator Subscription
The [`resources/tektoncd-operator-subscription.yaml`)(./resources/tektoncd-operator-subscription.yaml) file has been downloaded from the OperatorHub website to maintain consistency. To update the local file from the remote version run:

```bash
./scripts/re-download-tektoncd-operator-subscription-manifest.sh
```
