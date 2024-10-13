# Monitoring
Observability tools.

# Table Of Contents
- [Operations](#operations)

# Operations
## Port Forwarding
To access the Prometheus web UI:

``` shell
kubectl -n monitoring port-forward svc/prometheus 9000:80
```

To access the Alert Manager web UI:

``` shell
kubectl -n monitoring port-forward svc/alertmanager 9093:80
```
