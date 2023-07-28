# Media Server
Setup to acquire and view TV and movies.

# Table Of Contents
- [Instructions](#setup)
- [Operations](#operations)
- [Development](#development)

# Instructions
1. Create a copy of [`./bases/qbittorrent/pia-vpn-secret-patch.example.yaml`](./bases/qbittorrent/pia-vpn-secret-patch.example.yaml) named `pia-vpn-secret-patch.yaml`, fill in your own values

After the manifests have been applied follow the [Initial Setup](#initial-setup) instructions to connect all the services to each other.

# Operations
## Initial Setup
### qBittorrent
- Ensure WebUI host header verification is not enabled. If it is then you need to access the web UI by port forwarding the same port the web UI is running on (`8080`). The default login for the web UI is `admin:adminadmin`
- Ensure torrent management mode is manual
- Set completed downloads to save in `/media/downloads/complete`
- Set incomplete downloads to save in `/media/downloads/incomplete`


### Sonarr Initial Setup
- Add `/media/shows` as the root folder
- Add qBittorrent as a download client (Host: `qbittorrent`, port `80`)

### Radarr Initial Setup
- Add `/media/movies` as the root folder
- Add qBittorrent as a download client (Host: `qbittorrent`, port `80`)

### Prowlarr Initial Setup
- Add Sonarr as an application (Host: `sonarr`, port `80`)
- Add Radarr as an application (Host: `radarr`, port `80`)

### Emby Initial Setup
- When Emby first starts you must navigate to its dashboard to create an initial user
- Exec into the Emby pod to create a `/media/movies` and `/media/shows` directory. Then add those directories as libraries

### Jellyseerr Initial Setup
- When Jellyseerr first starts you navigate to the dashboard and connect it to the Emby server
- Add Sonarr as a service  (Host: `sonarr`, port `80`)
- Add Radarr as a service (Host: `radarr`, port `80`)

## Web UIs
### qBittorrent Web UI
To view the qBittorrent web UI use `kubectl` to forward the port locally:

```
kubectl -n media-server port-forward service/qbittorrent 8000:qb-web-ui
```

### Radarr Web UI
To view the Radarr web UI use `kubectl` to forward the port locally:

```
kubectl -n media-server port-forward service/radarr 8000:http
```

### Sonarr Web UI
To view the Sonarr web UI use `kubectl` to forward the port locally:

```
kubectl -n media-server port-forward service/sonarrl 8000:http
```

### Prowlarr Web UI
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