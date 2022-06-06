# Operator Lifecycle Manager
Installs the Operator Lifecycle Manager (OLM) component on the cluster.

# Table Of Contents
- [Overview](#overview)

# Overview
The Operator Lifecycle Manager facilitates installation of Kubernetes operators.

If you then want to install Kubernetes manifests which rely on the OLM use the [Terraform `depends_on` meta-argument](https://www.terraform.io/language/meta-arguments/depends_on) to indicate those resources require the OLM.
