{% set svc_name = "valorant-discord-bot" %}
{% set install_dir = "/opt/valorant-discord-bot" %}

valorant_discord_bot:
  # Git repository
  git_uri: git@github.com:WWPOL/valorant-discord-bot.git

  # Directory bot will be installed
  install_dir: {{ install_dir }}

  # Service
  svc_name: {{ svc_name }}
  svc_run_file: /etc/sv/{{ svc_name }}/run
  svc_finish_file: /etc/sv/{{ svc_name }}/finish

  # Configuration file
  secret_config_file: {{ install_dir }}/src/secret.config.js

  # Redis container
  redis_container_name: prod-valorant-discord-bot-redis
