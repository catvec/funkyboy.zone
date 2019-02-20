# funkyboy.zone
Linux server run at funkyboy.zone

# Table Of Contents
- [Overview](#overview)
- [The Name?](#the-name)
- [Cloud Setup](#cloud-setup)
- [First Time State Setup](#first-time-state-setup)
- [Custom Cloud Image Creation](#custom-cloud-image-creation)
- [Files](#files)

# Overview
Server is setup using [Salt](https://saltstack.com).  

# The Name?
**Why funkyboy.zone?**  
In one of my favorite movies, 
[Redline](https://en.wikipedia.org/wiki/Redline_(2009_film)), the antagonist 
has a secret weapon named "Funky Boy". I found this humorous, and decided to 
name my Linux server: Funky Boy.

# Cloud Setup
1. Clone down this repository and initialize the submodules
   ```
   git clone git@github.com:Noah-Huppert/funkyboy.zone.git
   cd funkyboy.zone
   git submodule update --init
   ```
   You must have access to the [funkyboy.zone-secrets](https://github.com/Noah-Huppert/funkyboy.zone-secrets)
   repository. This private repository holds secret setup information.

2. Setup cloud resources on DigitalOcean using [Terraform](https://terraform.io):
   ```
   ./client-scripts/setup-cloud.sh
   ```

3. Run the initial setup script:
   ```
   ./client-scripts/init.sh
   ```

# First Time Setup
This section contains one time setup steps which were manually run to create 
files in states.

## ZNC
The configuration file in the `znc` state was initially generated with 
the command:

```
znc --makeconf
```

This file was then further edited.

## Email
The keys for OpenDKIM in the `email-secret` state were generated with 
the command:

```
opendkim-genkey -s mail -d funkyboy.zone
```

These outputted `mail.private` and `mail.txt` files were renamed to 
`funkyboy-zone.private` and `funkyboy-zone.txt`.

The `funkyboy-zone-dkim` record in the `client-scripts/infra.tf` file is 
sourced from the `funkyboy-zone.txt` file.

## Prometheus
Make a secure admin password and store it in the `prometheus-secret` pillar.

Then log into Grafana and add Prometheus as a data source with 
default credentials.

# Custom Cloud Image Creation
One can create custom DigitalOcean Droplet images. These allow Droplets to run
custom operating systems.

To create a custom image complete the following steps:

1. Download installation media ISO
2. Create VirtualBox machine
3. Install operating system on virtual machine
4. Install Python 3 and Pip
5. Install Cloud Init
    - Download latest 
      [Cloud Init distribution](https://launchpad.net/cloud-init)
    - Extract download:
      ```
      tar -xzvf cloud-init-x.x.x.tar.gz
      ```
    - Build:
      ```
      cd cloud-init-x.x.x
      python3 setup.py build
      ```
    - Install:
      ```
      python3 setup.py install
      ```
    - Clean:
      ```
      cd ..
      rm -rf cloud-init*
      ```
6. Upload the virtual machine's disk image file `.vdi` to DigitalOcean spaces
7. Create a custom image on the DigitalOcean dashboard

# Files
- `server-scripts/` - Scripts to be run on the server
- `client-scripts/` - Scripts to be run on a client
- `{salt,pillar}/` - Salt files
