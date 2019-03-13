# Development
Instructions for developing Funky Boy setup files.

# Table Of Contents
- [First Time State Setup](#first-time-state-setup)
- [Custom Cloud Image Creation](#custom-cloud-image-creation)
- [Files](#files)

# First Time State Setup
This section contains one time setup steps which were manually run to create 
files in states.

## Wireguard
Generate a private key:

```
wg genkey
```

Save this value in the `wireguard.private_key` key of the 
`wireguard-secret` pillar.

Derive the public key by running:

```
echo "PRIVATE KEY" | wg pubkey
```

Save this value in the `wireguard.public_key` key of the `wireguard` pillar.

## Prometheus
A GitHub OAuth application is used to authenticate users when accessing 
Prometheus. Authentication is performed by Caddy.

Create a GitHub application and store the credentials:

Set `Authorization callback URL` to 
`https://prometheus.funkyboy.zone/login/github`.  

Save the client ID and secret values in the `prometheus-secret` pillar under 
the `github.client_id` and `github.client_secret` keys.

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

## Backup
System backups are saved in a Digtial Ocean Space.  

Store a Digital Ocean Spaces API key in the `backup-secret` pillar under the 
`backup.spaces_access_key_id` and `backup.spaces_secret_access_key` keys.

## Factorio
### Mods
Factorio mods are stored in a DigitalOcean space.

Store a Digital Ocean Spaces API key in the `factorio-secret` pillar under the
`factorio.spaces_access_key_id` and `factorio.spaces_secret_access_key` keys.  

### Save file
Once a game save file is present the backup cron job will save it and restore 
it if needed.

To bootstrap the first save file rsync your file 
to `/opt/factorio/saves/_autosave1.zip`. Ensure the `factorio` user and group
can access this file.

## GPG
Users can place their GPG keys on the server.  

Create a directory named `secret/salt/gpg-secret/$USER`. Inside the
directory run:

```
gpg --armor --export KEY_ID > pub.asc
gpg --armor --export-secret-keys KEY_ID > priv.asc
gpg --armor --export-ownertrust > trust.asc
```

Then add the user's name to the `gpg.user_keys` list in the `gpg` Pillar.

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
