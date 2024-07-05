# Monitoring
Observability tools.

# Table Of Contents
- [Development](#development)
- [Deployment](#deployment)
- [Operations](#operations)

# Development
Manifests were downloaded from the [Kube Prometheus repository](https://github.com/prometheus-operator/kube-prometheus/tree/v0.13.0). Since there are a lot of individual manifest files its recommended you download the tagged release commit of the repository as a zip file. Then extract it and move the files using the helper commands:

- `bases/kube-prometheus/crds/resources/` is downloaded from `manifests/setup/` in the Kube Prometheus repo
  - Move manifests into directory:
    ```shell
    cp ~/downloads/kube-prometheus-0.13.0/manifests/setup/*.yaml ./kubernetes/base/monitoring/resources/kube-prometheus/crds/resources/
    ```
  - To create the Kustomization `resources` list items:
    ```shell
     find kubernetes/base/monitoring/resources/kube-prometheus/crds/resources/ -type f | sort | sed 's/^.*\/\(.*\)\/\(.*\)/- \1\/\2/g'
    ```  
    
# Deployment
1. Deploy the CRDs component in `resources/kube-prometheus/crds/`
2. Wait for CRDs to be available:
   ```shell
   until kubectl get servicemonitors --all-namespaces ; do date; sleep 1; echo ""; done
   ```
   "No resources found" will be output when successful
3. Deploy the core component in `resources/kube-prometheus/core/`

# Operations## Grafana Dashboard
To access the Grafana dashboard run:

```shell
kubectl -n monitoring port-forward svc/grafana 3000:3000
```

## Prometheus Dashboard
To access the Prometheus dashboard run:

```shell
kubectl -n monitoring port-forward svc/prometheus-k8s 9090:9090
```

It will be accessible at [localhost:9090](http://localhost:9090)