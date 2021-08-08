# funkyboy.zone
Linux server run at funkyboy.zone

# Table Of Contents
- [Overview](#overview)
- [Cloud Setup](#cloud-setup)

# Overview
Server is setup using [Salt](https://saltstack.com).  

See [Cloud Setup](#cloud-setup) for instructions on how to setup Funky Boy.

See [DEVELOPMENT.md](DEVELOPMENT.md) for instructions on how to develop setup
files for Funky Boy.

**Why the name funkyboy.zone?**  
In one of my favorite movies, 
[Redline](https://en.wikipedia.org/wiki/Redline_(2009_film)), the antagonist 
has a secret weapon named "Funky Boy". I found this funny, and decided to 
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
2. Make a copy of `.env-example` named `.env`, edit your own values.
2. Setup cloud resources on DigitalOcean using [Terraform](https://terraform.io):
   ```
   ./client-scripts/setup-cloud.sh
   ```
3. Run the initial setup script:
   ```
   ./client-scripts/init.sh
   ```
4. (Optional) Restore data from a backup, ssh into the server and run:
   ```
   sudo su
   /opt/backup/run-restore.sh
   ```
