# Wireguard
Set up Wireguard VPN.

# Table Of Contents
- [Operations](#operations)
- [Development](#development)

# Operations
## Get Peer Configuration
To get the configuration for a peer read the `status.config` field of a WireguardPeer resource:

```
kubectl get wireguardpeer peer1 --template={{.status.config}}
```

# Development
## Operator
The contents of [`bases/operator/resources/operator.yaml`](./bases/operator/resources/operator.yaml) are taken from the [Wireguard Operator install instructions](https://github.com/jodevsa/wireguard-operator#how-to-deploy).

As of the v2.0.0 release this YAML is already namespaced to the `wireguard-system` namespace.

## Sidecar Container
Runs the Wireguard client with the configuration from a Wireguard CRD peer.

Create a container with the image `noahhuppert/wireguard-sidecar:latest` and set the `WIREGUARD_PEER` env var to the `WireguardPeer` created with the operator.

Example YAMLs:

```yaml

```

Build the container with:

```
docker build -t noahhuppert/wireguard-sidecar:latest ./containers/sidecar/
docker push noahhuppert/wireguard-sidecar:latest
```