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

Change the peer's `AllowedIPs` to `10.0.0.0/8` if you don't want to send all traffic through the VPN and instead only access the VPN's LAN (aka., split tunnel mode).

# Development
## Operator
The contents of [`bases/operator/resources/operator.yaml`](./bases/operator/resources/operator.yaml) are taken from the [Wireguard Operator install instructions](https://github.com/jodevsa/wireguard-operator#how-to-deploy).

As of the v2.0.0 release this YAML is already namespaced to the `wireguard-system` namespace.

## Network Parameters
The Wireguard operator in use hard codes the subnet and gateway information.

| **VPC CIDR** | 10.0.0.0/8 |
| **Peer Subnet CIDR** | 10.8.0.0/24 ([*](https://github.com/jodevsa/wireguard-operator/blob/73ff848b4c9e0b30627a3f639463cf8c3b2555f5/pkg/wireguard/wireguard.go#L37)) |
| **Gateway** | 10.8.0.1 ([*](https://github.com/jodevsa/wireguard-operator/blob/73ff848b4c9e0b30627a3f639463cf8c3b2555f5/pkg/wireguard/wireguard.go#L38)) |

The VPC CIDR seems to be the private network used within Kubernetes. The most specific `AllowedIPs` I could find for peers was this CIDR (Helped to use `traceroute`).