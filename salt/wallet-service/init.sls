# Installs and runs https://github.com/Noah-Huppert/wallet-service/ server.

# Source code
{{ pillar.wallet_service.git_uri }}:
  git.latest:
    - target: {{ pillar.wallet_service.install_dir }}
    - identity: salt://ssh-deploy-key-secret/deploy_key

# Service
{{ pillar.wallet_service.svc_run_file }}:
  file.managed:
    - source: salt://wallet-service/run
    - template: jinja
    - mode: 755
    - makedirs: True

{{ pillar.wallet_service.svc_finish_file }}:
  file.managed:
    - source: salt://wallet-service/finish
    - template: jinja
    - mode: 755
    - makedirs: True

{{ pillar.wallet_service.svc_name }}-enabled:
  service.enabled:
    - name: {{ pillar.wallet_service.svc_name }}
    - require:
      - file: {{ pillar.wallet_service.svc_run_file }}
      - file: {{ pillar.wallet_service.svc_finish_file }}

{{ pillar.wallet_service.svc_name }}-running:
  service.running:
    - name: {{ pillar.wallet_service.svc_name }}
    - reload: True
    - require:
      - service: {{ pillar.wallet_service.svc_name }}-enabled
    - watch:
      - git: {{ pillar.wallet_service.git_uri }}

# Reverse proxy
{{ pillar.caddy.config_dir }}/{{ pillar.wallet_service.caddyfile }}:
  file.managed:
    - source: salt://wallet-service/Caddyfile
    - template: jinja
    - group: {{ pillar.caddy.files.group }}
    - user: {{ pillar.caddy.files.user }}
    - mode: {{ pillar.caddy.files.mode }}
