# Headscale Operator

This directory contains the headscale-operator deployment manifests.

## Overview

The headscale-operator is a Kubernetes operator that manages Headscale instances (an open-source, self-hosted Tailscale control server alternative).

## Installation Method

Due to a bug in the upstream Helm chart (duplicate label keys), we generate and fix the manifests locally using a Python script.

### Prerequisites

- Python 3
- `helm` CLI installed and available in PATH
- Internet connection (to pull the chart)

### Generating Manifests

To regenerate the operator manifests (e.g., when upgrading to a new version):

```bash
./generate-manifests.py
```

This script:
1. Pulls the Helm chart from `oci://ghcr.io/infradohq/headscale-operator/charts/headscale-operator`
2. Generates Kubernetes manifests using `helm template`
3. Fixes duplicate label keys that cause kustomize build failures
4. Outputs `operator-manifests.yaml`

### Upgrading the Operator

To upgrade to a new version:

1. Edit `generate-manifests.py` and update the `CHART_VERSION` variable
2. Run `./generate-manifests.py`
3. Review the changes: `git diff operator-manifests.yaml`
4. Commit the updated manifest file

### Files

- `generate-manifests.py` - Script to generate and fix operator manifests
- `operator-manifests.yaml` - Generated operator deployment manifests (committed to git)
- `namespace.yaml` - Headscale namespace definition
- `kustomization.yaml` - Kustomize configuration that includes both files

### Known Issues

The upstream Helm chart (versions 0.1.0 through 0.1.3) has duplicate label keys:
- `app.kubernetes.io/managed-by` appears twice (once as "Helm", once as "helm")
- `app.kubernetes.io/name` appears twice

This causes kustomize to fail with:
```
yaml: unmarshal errors:
  line 15: mapping key "app.kubernetes.io/name" already defined at line 9
```

Our script automatically removes these duplicates by keeping only the first occurrence of each label key.

## Usage

This operator is deployed as part of the headscale component. The operator manages Headscale custom resources defined in `../headscale-instance/`.

See the [infradohq/headscale-operator GitHub repository](https://github.com/infradohq/headscale-operator) for more information about the operator and available CRDs.
