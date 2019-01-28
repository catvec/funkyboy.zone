# funkyboy.zone
Linux server run at funkyboy.zone

# Table Of Contents
- [Overview](#overview)
- [The Name?](#the-name?)
- [Setup](#setup)
- [Files](#files)

# Overview
Server is setup using [Salt](https://saltstack.com).  

# The Name?
**Why funkyboy.zone?**  
In one of my favorite movies, 
[Redline](https://en.wikipedia.org/wiki/Redline_(2009_film)), the antagonist 
has a secret weapon named "Funky Boy". I found this humorous, and decided to 
name my Linux server: Funky Boy.

# Setup
On your computer:

1. Run the initial setup script:
   ```
   ./client-scripts/init.sh root@funkyboy.zone
   ```
2. Setup rest of server:
   ```
   ./client-scripts/apply.sh root@funkyboy.zone
   ```

# Files
- `server-scripts/` - Scripts to be run on the server
- `client-scripts/` - Scripts to be run on a client
- `{salt,pillar}/` - Salt files
