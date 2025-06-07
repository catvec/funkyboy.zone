# IPMI ISO Fileshare
Run a Samba server for Supermicro IPMI software to find boot ISOs.

# Table Of Contents
- [Overview](#overview)
- [Usage](#usage)

# Overview
Only run when needed via a developer's laptop. Be sure to connect to the IPMI VLAN.

# Usage
Run on a host which is part of the IPMI VLAN.

All files in [`share/`](./share) are available on the Samba server.

## Start Server
1. Make a copy of [`secret.example.env`](./secret.example.env) named `secret.env` with your own values
2. Start the Docker compose stack:
   ``` shell
   docker compose up -d
   ```
   
## Connecting
To connect specify the following options:

| Option            | Value                                    |
| **Share host**    | IP of Samba server (ex., 10.10.10.x)     |
| **Path to image** | `\Data\debian-12.6.0-amd64-netinst.iso`  |
| **User**          | `USER` from [`secret.env`](./secret.env) |
| **Password**      | `PASS` from [`secret.env`](./secret.env) |
