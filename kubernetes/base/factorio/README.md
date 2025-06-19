# Factorio
Factorio game server.

# Table Of Contents
- [Overview](#overview)
- [Setup](#setup)
- [Partial Teardown](#partial-teardown)
- [Development](#development)

# Overview
Runs a Factorio server.

# Setup

1. Go to your [Factorio profile page](https://www.factorio.com/profile) and get your token and username
2. Make a copy of [`conf/server-config.env.example`](./conf/server-config.env.example) named `server-config.env`
  - Fill in your username
3. Make a copy of [`conf/server-secret.env.example`](./conf/server-secret.env.example) named `server-secret.env`
   - Fill in your token
4. Make a copy of [`conf/server-rconpw.txt.example`](./conf/server-rconpw.txt.example) named `server-rconpw.txt`
   - Make up a random password, put this in the file with a newline at the end
   
# Partial Teardown
Since the Factorio server needs a load balancer it can be a bit expensive to keep up when you don't need it. However you may want to also preserve the game save.

One solution is to scale the stateful set to 0 replicas and delete the service:

1. In the [`kustomization.yaml`](./kustomization.yaml) file uncomment the following:
   ```yaml
   replicas:
     - name: factorio
       count: 0
   ```
2. Delete the service:
  - In the [`kustomization.yaml`](./kustomization.yaml) file comment out the `resources/service.yaml` file in the `.resources` section. 
  - Delete the service with `kubectl`:
    ```sh
    kubectl -n factorio delete svc factorio-rev1
    ```
    
To enable do the opposite of these steps in reverse.

# Development
If a breaking change needs to be made to the StatefulSet (some fields on a StatefulSet cannot be updated without recreating the StatefulSet) the revision pattern is used:

- The StatefulSet and Service resource names should have a `-rev<n>` postfix (ex., `-rev5`)
- Use a matching `revision: revn` (ex., `rev5`) label on the StatefulSet metadata and selector and the service's selector

Increment the revision number to deploy a new change. Then edit the domains Terraform to point `factorio.funkyboy.zone` to the new service name. After you are confident the new revision is working you can delete the old revision's StatefulSet, Service, and optionally PersistentVolumeClaims and PersistentVolumes.
