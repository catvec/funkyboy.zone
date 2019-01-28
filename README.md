# funkyboy.zone
linux server run at funkyboy.zone

# Table Of Contents
- [Overview](#overview)
- [Setup](#setup)
- [Files](#files)

# Overview
Server is setup using [Salt](https://saltstack.com).  

# Setup
1. Run the initial setup script:
   ```
   ./client-scripts/init.sh ADDRESS
   ```

# Files
- `server-scripts/` - Scripts to be run on the server
- `client-scripts/` - Scripts to be run on a client
- `{salt,pillar}/` - Salt files
