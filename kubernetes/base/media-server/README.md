# Media Server
Setup to acquire and view TV and movies.

# Table Of Contents
- [Instructions](#setup)
- [Operations](#operations)

# Instructions
1. Create a copy of [`./bases/qbittorrent/pia-vpn-secret-patch.example.yaml`](./bases/qbittorrent/pia-vpn-secret-patch.example.yaml) named `pia-vpn-secret-patch.yaml`, fill in your own values

# Operations
## Emby Initial Setup
- When Emby first starts you must navigate to its dashboard to create an initial user
- Exec into the Emby pod to create a `/media/movies` and `/media/shows` directory. Then add those directories as libraries