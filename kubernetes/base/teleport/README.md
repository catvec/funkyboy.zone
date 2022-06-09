# Teleport
Installs the [Teleport](https://goteleport.com) access control platform.

# Table Of Contents
- [Overview](#overview)
- [Instructions](#instructions)

# Overview
The Teleport platform manages users and grants access to services within the Kubernetes cluster.

# Instructions
## Updating Teleport
The Teleport repository is a Git sub-module in the [`./base/teleport`](./base/teleport) directory. To update the version of Teleport used:

1. Checkout a new commit in the sub-module
2. Run:
   ```bash
   ./scripts/render-chart.sh
   ```
   This will convert the Teleport Helm chart into a plain manifest file.
