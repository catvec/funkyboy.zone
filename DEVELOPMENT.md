# Development
Instructions for developing Funky Boy setup files.

# Table Of Contents
- [First Time State Setup](#first-time-state-setup)
- [Custom Cloud Image Creation](#custom-cloud-image-creation)
- [Files](#files)

# First Time State Setup
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

# Custom Cloud Image Creation
One can create custom DigitalOcean Droplet images. These allow Droplets to run
custom operating systems.

The custom images which have already been created with these steps can be
found [here](https://custom-images.sfo2.digitaloceanspaces.com).

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
      tar -xzf cloud-init-x.x.x.tar.gz
      ```
    - Build:
      ```
      cd cloud-init-x.x.x
      pip3 install -r requirements.txt
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
