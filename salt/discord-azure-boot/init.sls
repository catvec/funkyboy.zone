# Install and run the discord-azure-boot bot

# Install
{{ pillar.discord_azure_boot.git_repo }}:
  git.latest:
    - target: {{ pillar.discord_azure_boot.dir }}

{{ pillar.discord_azure_boot.config_file }}:
  file.managed:
    - source: salt://discord-azure-boot-secret/config.ts
    - require:
      - git: {{ pillar.discord_azure_boot.git_repo }}

{{ pillar.discord_azure_boot.svc_file }}:
  file.managed:
    - source: salt://discord-azure-boot/run
    - template: jinja
    - mode: 755
    - makedirs: True

# Start service
{{ pillar.discord_azure_boot.svc }}-enabled:
  service.enabled:
    - name: {{ pillar.discord_azure_boot.svc }}
    - require:
      - git: {{ pillar.discord_azure_boot.git_repo }}
      - file: {{ pillar.discord_azure_boot.config_file }}
      - file: {{ pillar.discord_azure_boot.svc_file }}

{{ pillar.discord_azure_boot.svc }}-running:
  service.running:
    - name: {{ pillar.discord_azure_boot.svc }}
    - require:
      - service: {{ pillar.discord_azure_boot.svc }}-enabled
    - watch:
      - git: {{ pillar.discord_azure_boot.git_repo }}
      - file: {{ pillar.discord_azure_boot.config_file }}
      - file: {{ pillar.discord_azure_boot.svc_file }}
