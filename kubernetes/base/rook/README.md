# Rook
Ceph file and object storage operator.

# Table Of Contents
- [Development](#development)
- [Operation](#operation)

# Development
The `crds.yaml`, `common.yaml`, `operator.yaml`, and `cluster-on-pvc.yaml` (renamed to `cluster.yaml`) files were downloaded from the `deploy/examples/` directory of the [Rook repository](https://github.com/rook/rook/).

# Operation
To access the dashboard port forward the `rook-ceph-mgr-dashboard` service:

```
kubectl -n rook-ceph port-forward service/rook-ceph-mgr-dashboard :7000
```

To login use the `admin` username and the password stored in the `rook-ceph-dashboard-password` secret, which can be retrieved via:

```
kubectl -n rook-ceph get secret rook-ceph-dashboard-password -o jsonpath="{['data']['password']}" | base64 --decode && echo
```