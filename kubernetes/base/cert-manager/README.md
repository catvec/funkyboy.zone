# Cert Manager
Lets Encrypt certificate bot.

# Table Of Contents
- [Overview](#overview)
- [Instructions](#instructions)
- [Development](#development)

# Overview
[Cert Manager](https://cert-manager.io/).

# Instructions
In both `lets-encrypt-production/` and `lets-encrypt-staging/` create a copy of `acme-email-patch.example.yaml` named `acme-email-patch.yaml`. Fill in the value field with your email used for ACME certificate issuing.

# Development
Install manifests for `bases/install/manifests.yaml` are from: https://github.com/cert-manager/cert-manager/releases/download/v1.10.1/cert-manager.yaml