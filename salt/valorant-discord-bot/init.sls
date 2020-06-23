# Installs and runs https://github.com/WWPOL/valorant-discord-bot.

{{ pillar.valorant_discord_bot.git_uri }}:
  git.latest:
    - target: {{ pillar.valorant_discord_bot.install_dir }}
    - identity: salt://ssh-deploy-key-secret/deploy_key

{{ pillar.valorant_discord_bot.secret_config_file }}:
  file.managed:
    - source: salt://valorant-discord-bot-secret/secret.config.js
    - template: jinja
    - require:
      - git: {{ pillar.valorant_discord_bot.git_uri }}

{{ pillar.valorant_discord_bot.svc_run_file }}:
  file.managed:
    - source: salt://valorant-discord-bot/run
    - template: jinja
    - mode: 755
    - makedirs: True

{{ pillar.valorant_discord_bot.svc_finish_file }}:
  file.managed:
    - source: salt://valorant-discord-bot/finish
    - template: jinja
    - mode: 755
    - makedirs: True

{{ pillar.valorant_discord_bot.svc_name }}-enabled:
  service.enabled:
    - name: {{ pillar.valorant_discord_bot.svc_name }}
    - require:
      - file: {{ pillar.valorant_discord_bot.svc_run_file }}
      - file: {{ pillar.valorant_discord_bot.svc_finish_file }}
      - file: {{ pillar.valorant_discord_bot.secret_config_file }}

{{ pillar.valorant_discord_bot.svc_name }}-running:
  service.running:
    - name: {{ pillar.valorant_discord_bot.svc_name }}
    - reload: True
    - require:
      - service: {{ pillar.valorant_discord_bot.svc_name }}-enabled
    - watch:
      - git: {{ pillar.valorant_discord_bot.git_uri }}
      - file: {{ pillar.valorant_discord_bot.secret_config_file }}
