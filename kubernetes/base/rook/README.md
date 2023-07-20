# Rook
Ceph file and object storage operator.

# Table Of Contents
- [Development](#development)
- [Operation](#operation)

# Development
The base files from which manifests were based on come from the [Rook repository](https://github.com/rook/rook/):

- `/bases/operator/resources/`
  - `crds.yaml` from Rook repo `/deploy/examples/crds.yaml`
  - `common.yaml` from Rook repo `/deploy/examples/common.yaml`
  - `operator.yaml` from Rook repo `/deploy/examples/operator.yaml`
- `/bases/cluster/resources/`
  - `cluster.yaml` from Rook repo `/deploy/examples/cluster-on-pvc.yaml`
  - `storageclass.yaml` and `ceph-block-poo.yaml` from Rook repo `/deploy/examples/csi/rbd/storageclass.yaml`

# Operation
To access the dashboard port forward the `rook-ceph-mgr-dashboard` service:

```
kubectl -n rook-ceph port-forward service/rook-ceph-mgr-dashboard :7000
```

To login use the `admin` username and the password stored in the `rook-ceph-dashboard-password` secret, which can be retrieved via:

```
kubectl -n rook-ceph get secret rook-ceph-dashboard-password -o jsonpath="{['data']['password']}" | base64 --decode && echo
```