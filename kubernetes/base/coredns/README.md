# CoreDNS
Cluster internal DNS server.

# Table Of Contents
- [Overview](#overview)

# Overview
The Kubernetes cluster runs a DNS server internally by default. The set of manifests in this folder override the config map which this DNS server uses. With the goal of hosting a custom DNS zone: `infoline.funkyboy.zone`. Within the cluster this custom zone isn't too much good. But it can prove useful for Wireguard VPN peers to access services in a shorthand manner.  