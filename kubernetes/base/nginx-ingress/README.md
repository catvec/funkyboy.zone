# Nginx Ingress
Nginx powered ingress controller.

# Table Of Contents
- [Overview](#overview)

# Overview
Digital Ocean specific Nginx ingress controller.

Setup using these [instructions](https://kubernetes.github.io/ingress-nginx/deploy/#digital-ocean). The `./base/manifests.yaml` file contains the contents of the curl.

The patch to add the `service.beta.kubernetes.io/do-loadbalancer-hostname` annotation to the nginx ingress controller service is essential to make `cert-manager` work. Due to [an issue](https://github.com/cert-manager/cert-manager/issues/3238#issuecomment-733541778) with how Kubernetes DNS works inside of pods.