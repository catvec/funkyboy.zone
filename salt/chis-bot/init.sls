# Installs and runs the git@github.com:Chrisae9/chis-bot.git Discord Bot
# from Chis.

# Source code
{{ pillar.chis_bot.git_uri }}:
  git.latest:
    - target: {{ pillar.chis_bot.install_dir }}
    #- identity: salt://ssh-deploy-key-secret/deploy_key

# Config file
{{ pillar.chis_bot.secret_config_file }}:
  file.managed:
    - source: salt://chis-bot-secret/config.json
    - mode: 755
    - makedirs: True

# Service
{{ pillar.chis_bot.svc_run_file }}:
  file.managed:
    - source: salt://chis-bot/run
    - template: jinja
    - mode: 755
    - makedirs: True

{{ pillar.chis_bot.svc_log_file }}:
  file.managed:
    - source: salt://chis-bot/log
    - template: jinja
    - mode: 755
    - makedirs: True      

{{ pillar.chis_bot.svc_name }}-enabled:
  service.enabled:
    - name: {{ pillar.chis_bot.svc_name }}
    - require:
      - git: {{ pillar.chis_bot.git_uri }}
      - file: {{ pillar.chis_bot.svc_run_file }}
      - file: {{ pillar.chis_bot.svc_log_file }}
      - file: {{ pillar.chis_bot.secret_config_file }}

{{ pillar.chis_bot.svc_name }}-running:
  service.running:
    - name: {{ pillar.chis_bot.svc_name }}
    - reload: True
    - require:
      - service: {{ pillar.chis_bot.svc_name }}-enabled
    - watch:
      - git: {{ pillar.chis_bot.git_uri }}
      - file: {{ pillar.chis_bot.svc_run_file }}
      - file: {{ pillar.chis_bot.svc_log_file }}
      - file: {{ pillar.chis_bot.secret_config_file }}
