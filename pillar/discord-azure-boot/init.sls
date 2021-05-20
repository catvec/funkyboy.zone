{% set dir = "/opt/discord-azure-boot" %}
{% set svc = "discord-azure-boot" %}
{% set svc_dir = "/etc/sv/" + svc %}

discord_azure_boot:
  dir: {{ dir }}
  git_repo: https://github.com/Noah-Huppert/discord-azure-boot.git

  config_file: {{ dir }}/config.ts

  svc: {{ svc }}
  svc_file: {{ svc_dir }}/run
