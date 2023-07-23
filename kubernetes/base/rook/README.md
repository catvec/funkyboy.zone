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
  - `filesystem.yaml` from Rook repo `/deploy/examples/filesystem.yaml`

# Operation
## Dashboard
To access the dashboard port forward the `rook-ceph-mgr-dashboard` service:

```
kubectl -n rook-ceph port-forward service/rook-ceph-mgr-dashboard :7000
```

To login use the `admin` username and the password stored in the `rook-ceph-dashboard-password` secret, which can be retrieved via:

```
kubectl -n rook-ceph get secret rook-ceph-dashboard-password -o jsonpath="{['data']['password']}" | base64 --decode && echo
```

## Toolbox
A pod with Ceph credentials and the Ceph CLI is running under the deployment `rook-ceph-tools`.

Get the pod's name:

```
kubectl -n rook-ceph get pod -l app=rook-ceph-tools
```

Create a bash prompt in the pod:

```
kubectl -n rook-ceph exec it <POD NAME> /bin/bash
```

## Changing Dashboard Config
The Ceph cluster CRD has fields to configure if the dashboard uses SSL and what port it listens on. As of 7/22/23 if you change these fields after creating a cluster then your changes will not be reflected in the Ceph managers.

Instead you must use the Ceph CLI to set these settings:

- Port: `ceph config set mgr mgr/dashboard/server_port <PORT>`
- SSL: `ceph config set mgr mgr/dashboard/ssl <true|false>`

Then you must restart the Ceph manager pods one at a time. To find the pods:

```
kubectl -n rook-ceph get pod -l app=rook-ceph-mgr -l rook_cluster=rook-ceph -l ceph_daemon_type=mgr
```