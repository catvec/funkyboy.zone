# Monitoring
Observability tools.

# Table Of Contents
- [Operations](#operations)

# Operations
## Port Forwarding
To access the Prometheus web UI:

``` shell
kubectl -n monitoring port-forward svc/prometheus 8000:80
```
