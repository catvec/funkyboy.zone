# Monitoring
Observability tools.

# Table Of Contents
- [Development](#development)
- [Operations](#operations)

# Development
The Prometheus container needs the `65534` file system group to access files on the mount.

The RBAC setup from the [Prometheus Kubernetes Tutorial](https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/user-guides/getting-started.md) was used.

The [example Kubernetes service discovery configuration](https://github.com/prometheus/prometheus/blob/main/documentation/examples/prometheus-kubernetes.yml) was used.

# Operations
To access the Prometheus dashboard run:

```
kubectl -n monitoring port-forward service/prometheus-operated 9090:9090 &
kubectl -n monitoring port-forward service/alertmanager-operated 9093:9093 &
```