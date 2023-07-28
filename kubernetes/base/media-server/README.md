# Media Server
Setup to acquire and view TV and movies.

# Table Of Contents
- [Instructions](#setup)
- [Operations](#operations)
- [Development](#development)

# Instructions
1. Create a copy of [`./bases/qbittorrent/pia-vpn-secret-patch.example.yaml`](./bases/qbittorrent/pia-vpn-secret-patch.example.yaml) named `pia-vpn-secret-patch.yaml`, fill in your own values

# Operations
## Emby Initial Setup
- When Emby first starts you must navigate to its dashboard to create an initial user
- Exec into the Emby pod to create a `/media/movies` and `/media/shows` directory. Then add those directories as libraries

## Jellyseerr Initial Setup
- When Jellyseerr first starts you navigate to the dashboard and connect it to the Emby server

## qBittorrent Web UI
To view the qBittorrent web UI use `kubectl` to forward the port locally:

```
kubectl -n media-server port-forward service/qbittorrent 8000:qb-web-ui
```

## Radarr Web UI
To view the Radarr web UI use `kubectl` to forward the port locally:

```
kubectl -n media-server port-forward service/radarr 8000:http
```

## Sonarr Web UI
To view the Sonarr web UI use `kubectl` to forward the port locally:

```
kubectl -n media-server port-forward service/sonarrl 8000:http
```

## Prowlarr Web UI
To view the Prowlarr web UI use `kubectl` to forward the port locally:

```
kubectl -n media-server port-forward service/prowlarr 8000:http
```

# Development
## qBittorrent Pod Network Policies
To restrict the qBittorrent application from being accessed or making requests that are not through the VPN a `NetworkPolicy` is put in place.

The IPs for the VPN were retrieved from the Gluetun container's data:

```
curl -L https://github.com/qdm12/gluetun/raw/eecfb3952f202c0de3867d88e96d80c6b0f48359/internal/storage/servers.json | jq '.["private internet access"].servers[] | select(.region == "US New York")'
```

(Be sure to get the correct SHA for the URL based on the version of Gluetun being used, additionally update the region if needed)