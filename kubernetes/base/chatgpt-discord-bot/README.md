# Chat GTP Discord Bot
Discord bot running GTP3.

# Table Of Contents
- [Overview](#overview)
- [Instructions](#instructions)
- [Development](#development)

# Overview
[chatGPT-discord-bot GitHub repository](https://github.com/Zero6992/chatGPT-discord-bot).

# Instructions
1. Create a copy of [`production/config.example.json`](./production/config.example.json) named `production/config.json`

# Development
Right now there is not a commonly distributed Docker image so you must build your own:

1. Clone down the [chatGPT-discord-bot repository](https://github.com/Zero6992/chatGPT-discord-bot)
2. Checkout the latest tagged release:
   ```
   git checkout vx.y.z
   ```
3. Build the docker image:
   ```
   docker build -t username/chatgpt-discord-bot:vx.y.z .
   ```
4. Push the image
   ```
   docker push username/chatgpt-discord-bot:vx.y.z
   ```