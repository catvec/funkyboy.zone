# Minio
Object storage.

# Table Of Contents
- [Overview](#overview)
- [Instructions](#instructions)
- [Development](#development)

# Overview
[Minio](https://min.io/) operator.

# Instructions
1. Make a copy of [`bases/tenant/storage-config-secret-patch.example.yaml`](./bases/tenant/storage-config-secret-patch.example.yaml) named `storage-config-secret-patch.yaml and replace the values with your own base64 encoded values
2. Make a copy of [`bases/tenant/storage-user-config-secret-patch.example.yaml`](./bases/tenant/storage-user-config-secret-patch.example.yaml) named `storage-user-config-secret-patch.yaml`, replace the values with your own base64 encoded values

# Development
[Minio Operator](https://operatorhub.io/operator/minio-operator) manifest from [this url](https://operatorhub.io/install/minio-operator.yaml).

Minio Tenant YAML from [Minio Kustomization Example](https://github.com/minio/operator/tree/master/examples/kustomization/base)