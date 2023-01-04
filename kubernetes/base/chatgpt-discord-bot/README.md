# Chat GTP Discord Bot
Discord bot running GTP3.

# Table Of Contents
- [Overview](#overview)
- [Instructions](#instructions)
- [Development](#development)

# Overview
[chatGPT-discord-bot GitHub repository](https://github.com/Zero6992/chatGPT-discord-bot).

# Instructions
1. For each directory in [`overlays/`](./overlays/) follow these steps:
   - Create a copy of `overlays/<overlay>/config.example.env` named `overlays/<overlay>/config.env`

# Development
The `bases/` directory contains manifests for components. The `overlays/` directory contains different deployments of the bot. The `deploy/` directory combines the overlays and Redis base.