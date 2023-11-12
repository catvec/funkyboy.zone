# Headscale
Self hosted Tail Scale control server.

# Table Of Contents
- [Development](#development)
- [Operations](#operations)

# Development
The [`resources/config-map.yaml`](./resources/config-map.yaml) ConfigMap is derived from the [`config-example.yaml` file from the Headscale repo](https://github.com/juanfont/headscale/blob/v0.22.3/config-example.yaml).

# Operations
Many operations require the `headscale` CLI. Create a shell in the Headscale control server pod to access this:

```
kubectl -n headscale exec -it deployment/headscale -- /bin/bash
```

## Create A New User
```
headscale users create <USER>
```

## Login User
On the Android app tap the 3 dot menu 3 times, change the server to `https://control.headscale.k8s.funkyboy.zone`. 

When you click the login button the user will see a command in this form to run:

```
headscale nodes register --user <USER> --key nodekey:<KEY>
```

To login with the Tailscale CLI:

```
tailscale up --login-server https://control.headscale.k8s.funkyboy.zone
```

## API Key
For the web ui to work it needs an API key, generate it:

```
headscale apikeys create --expiration 90d
```