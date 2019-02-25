# Installs and runs a Factorio server.
#
# Creates a factorio user and group.
# Pulls down Docker image.
# Places factorio configuration files.
# Starts service which runs factorio server.
# Configures caddy to serve the factorio mods directory.

# Factorio user
{{ pillar.factorio.group.name }}-group:
  group.present:
    - name: {{ pillar.factorio.group.name }}
    - gid: {{ pillar.factorio.group.id }}

{{ pillar.factorio.user.name }}-user:
  user.present:
    - name: {{ pillar.factorio.user.name }}
    - createhome: False
    - uid: {{ pillar.factorio.user.id }}
    - gid: {{ pillar.factorio.group.id }}
    - groups:
      - docker
    - require:
      - group: {{ pillar.factorio.group.name }}-group

# Docker image
{{ pillar.factorio.docker_image }}:
  docker_image.present

# Configuration
{{ pillar.factorio.directory }}:
  file.directory:
    - user: {{ pillar.factorio.user.name }}
    - group: {{ pillar.factorio.group.name }}
    - file_mode: {{ pillar.factorio.mode }}
    - dir_mode: {{ pillar.factorio.mode }}
    - require:
      - user: {{ pillar.factorio.user.name }}-user
      - group: {{ pillar.factorio.group.name }}-group

{{ pillar.factorio.factorio_config.directory }}:
  file.directory:
    - user: {{ pillar.factorio.user.name }}
    - group: {{ pillar.factorio.group.name }}
    - file_mode: {{ pillar.factorio.mode }}
    - dir_mode: {{ pillar.factorio.mode }}
    - require:
      - file: {{ pillar.factorio.directory }}

{{ pillar.factorio.factorio_config.file }}:
  file.managed:
    - source: salt://factorio/server-settings.json
    - template: jinja
    - user: {{ pillar.factorio.user.name }}
    - group: {{ pillar.factorio.group.name }}
    - mode: {{ pillar.factorio.mode }}
    - require:
      - file: {{ pillar.factorio.factorio_config.directory }}

# Mods
{{ pillar.factorio.check_mods_script }}:
  file.managed:
    - source: salt://factorio/check-mods.sh
    - user: {{ pillar.factorio.user.name }}
    - group: {{ pillar.factorio.group.name }}
    - mode: {{ pillar.factorio.mode }}
    - require:
      - file: {{ pillar.factorio.directory }}

{{ pillar.factorio.run_check_mods_script }}:
  file.managed:
    - source: salt://factorio/run-check-mods.sh
    - template: jinja
    - user: {{ pillar.factorio.user.name }}
    - group: {{ pillar.factorio.group.name }}
    - mode: {{ pillar.factorio.mode }}
    - require:
      - file: {{ pillar.factorio.directory }}

{{ pillar.factorio.copy_mods_script }}:
  file.managed:
    - source: salt://factorio/copy-mods.sh
    - user: {{ pillar.factorio.user.name }}
    - group: {{ pillar.factorio.group.name }}
    - mode: {{ pillar.factorio.mode }}
    - require:
      - file: {{ pillar.factorio.directory }}

{{ pillar.factorio.run_copy_mods_script }}-managed:
  file.managed:
    - name: {{ pillar.factorio.run_copy_mods_script }}
    - source: salt://factorio/run-copy-mods.sh
    - template: jinja
    - user: {{ pillar.factorio.user.name }}
    - group: {{ pillar.factorio.group.name }}
    - mode: {{ pillar.factorio.mode }}
    - require:
      - file: {{ pillar.factorio.directory }}

{{ pillar.factorio.run_copy_mods_script }}-run:
  cmd.run:
    - name: {{ pillar.factorio.run_copy_mods_script }}
    - unless: {{ pillar.factorio.run_check_mods_script }}
    - require:
      - file: {{ pillar.factorio.run_check_mods_script }}
      - file: {{ pillar.factorio.run_copy_mods_script }}-managed

{{ pillar.factorio.mods_directory }}:
  file.directory:
    - user: {{ pillar.factorio.user.name }}
    - group: {{ pillar.factorio.group.name }}
    - file_mode: {{ pillar.factorio.mode }}
    - dir_mode: {{ pillar.factorio.mode }}
    - require:
      - file: {{ pillar.factorio.directory }}
      - cmd: {{ pillar.factorio.run_copy_mods_script }}-run

# Save directory
{{ pillar.factorio.saves_directory }}:
  file.directory:
    - user: {{ pillar.factorio.user.name }}
    - group: {{ pillar.factorio.group.name }}
    - file_mode: {{ pillar.factorio.mode }}
    - dir_mode: {{ pillar.factorio.mode }}
    - recurse:
      - user
      - group
      - mode
    - require:
      - file: {{ pillar.factorio.directory }}

# Factorio server service
{{ pillar.factorio.factorio_service.directory }}:
  file.directory

{{ pillar.factorio.factorio_service.run_file }}:
  file.managed:
    - source: salt://factorio/run
    - mode: 755
    - template: jinja

{{ pillar.factorio.factorio_service.finish_file }}:
  file.managed:
    - source: salt://factorio/finish
    - mode: 755
    - template: jinja

{{ pillar.factorio.factorio_service.name }}-enabled:
  service.enabled:
    - name: {{ pillar.factorio.factorio_service.name }}
    - require:
      - file: {{ pillar.factorio.factorio_service.run_file }}
      - user: {{ pillar.factorio.user.name }}-user
      - file: {{ pillar.factorio.factorio_config.file }}
      - file: {{ pillar.factorio.mods_directory }}

{{ pillar.factorio.factorio_service.name }}-running:
  service.running:
    - name: {{ pillar.factorio.factorio_service.name }}
    - require:
      - service: {{ pillar.factorio.factorio_service.name }}-enabled
    - watch:
      - file: {{ pillar.factorio.factorio_service.run_file }}
      - file: {{ pillar.factorio.factorio_config.file }}
      - file: {{ pillar.factorio.mods_directory }}
      - docker_image: {{ pillar.factorio.docker_image }}

# Caddy
{{ pillar.caddy.config_dir }}/{{ pillar.factorio.caddy_cfg_file }}:
  file.managed:
    - source: salt://factorio/Caddyfile
    - template: jinja
    - user: {{ pillar.caddy.files.user }}
    - group: {{ pillar.caddy.files.group }}
    - mode: {{ pillar.caddy.files.mode }}
