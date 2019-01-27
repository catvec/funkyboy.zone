# funkyboy.zone
linux server run at funkyboy.zone

# Table Of Contents
- [Overview](#overview)
- [Setup](#setup)

# Overview
Server is setup using [Salt](https://saltstack.com).  

# Setup
Put this repository in the `/opt/salt` folder on the server.  

To setup the repository run:

```
mkdir -p /srv
ln -s /opt/salt/salt /srv/salt
ln -s /opt/salt/pillar /srv/pillar
```

Then execute the following commands to setup the server:

```
salt-call --local state.apply
```
