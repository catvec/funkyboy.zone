# Wireguard
Set up Wireguard VPN.

# Table Of Contents
- [Operations](#operations)
- [Development](#development)

# Operations
Allows access to the internal Kubernetes cluster DNS. Use the following format to access a service in a namespace.

```
<Service>.<Namespace>.svc.cluster.local
```
## Get Peer Configuration
To get the configuration for a peer read the `status.config` field of a WireguardPeer resource:

```
kubectl -n wireguard get wireguardpeer <PEER> --template={{.status.config}} | bash
```

# Development
## Operator
The contents of [`bases/operator/resources/operator.yaml`](./bases/operator/resources/operator.yaml) are taken from the [Wireguard Operator install instructions](https://github.com/jodevsa/wireguard-operator#how-to-deploy).

As of the v2.0.0 release this YAML is already namespaced to the `wireguard-system` namespace.
