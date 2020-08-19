{% set svc_name = "chis-bot" %}
{% set install_dir = "/opt/chis-bot" %}

chis_bot:
  # Git repository
  git_uri: https://github.com/Chrisae9/chis-bot.git

  # Directory bot will be installed
  install_dir: {{ install_dir }}

  # Service
  svc_name: {{ svc_name }}
  svc_run_file: /etc/sv/{{ svc_name }}/run
  svc_log_file: /etc/sv/{{ svc_name }}/log/run

  # Configuration file
  secret_config_file: {{ install_dir }}/config.json
