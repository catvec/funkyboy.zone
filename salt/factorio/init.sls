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

{{ pillar.factorio.mods_access_group.name }}-group:
  group.present:
    - name: {{ pillar.factorio.mods_access_group.name }}
    - gid: {{ pillar.factorio.mods_access_group.id }}

{{ pillar.factorio.user.name }}-user:
  user.present:
    - name: {{ pillar.factorio.user.name }}
    - createhome: False
    - home: /
    - shell: {{ pillar.users_nologin_shell }}
    - uid: {{ pillar.factorio.user.id }}
    - gid: {{ pillar.factorio.group.id }}
    - groups:
      - docker
      - {{ pillar.factorio.mods_access_group.name }}
    - require:
      - group: {{ pillar.factorio.group.name }}-group
      - group: {{ pillar.factorio.mods_access_group.name }}-group

# Factorio admins group
{{ pillar.factorio.admin_group.name }}-group:
  group.present:
    - name: {{ pillar.factorio.admin_group.name }}
    - gid: {{ pillar.factorio.admin_group.id }}

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
    - mode: 750
    - require:
      - file: {{ pillar.factorio.factorio_config.directory }}

# Mods
{{ pillar.factorio.mod_list_f }}:
  file.absent:
    - prereq:
      - mount: {{ pillar.factorio.mods_directory }}

{{ pillar.factorio.mods_directory }}:
  mount.mounted:
    - device: {{ pillar.factorio.mods_space }}
    - fstype: fuse.s3fs
    - mkmnt: True
    - device_name_regex:
      - s3fs
      - {{ pillar.factorio.mods_space }}
    - opts:
      - allow_other
      - passwd_file={{ pillar.s3fs.passwd_file }}
      - use_path_request_style
      - url=https://{{ pillar.digitalocean_spaces.spaces_region }}.digitaloceanspaces.com
      - uid={{ pillar.factorio.user.id }}
      - gid={{ pillar.factorio.mods_access_group.id }}
      - umask=002
      - mp_umask=002
      - nonempty
    - extra_mount_invisible_keys:
      - passwd_file
      - use_path_request_style
      - url
      - uid
      - gid
      - umask
      - mp_umask
      - nonempty
    - persist: True

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

{{ pillar.factorio.factorio_service.log_file }}:
  file.managed:
    - source: salt://factorio/log
    - mode: 755
    - makedirs: true

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
      - file: {{ pillar.factorio.factorio_service.log_file }}
      - file: {{ pillar.factorio.factorio_service.finish_file }}
      - user: {{ pillar.factorio.user.name }}-user
      - file: {{ pillar.factorio.factorio_config.file }}

{{ pillar.factorio.factorio_service.name }}-running:
  service.running:
    - name: {{ pillar.factorio.factorio_service.name }}
    - require:
      - service: {{ pillar.factorio.factorio_service.name }}-enabled
    - watch:
      - file: {{ pillar.factorio.factorio_service.run_file }}
      - file: {{ pillar.factorio.factorio_service.log_file }}
      - file: {{ pillar.factorio.factorio_service.finish_file }}
      - file: {{ pillar.factorio.factorio_config.file }}
      - docker_image: {{ pillar.factorio.docker_image }}
      - mount: {{ pillar.factorio.mods_directory }}

{{ pillar.factorio.factorio_service.supervise_directory }}:
  file.directory:
    - group: {{ pillar.factorio.admin_group.name }}
    - mode: 775
    - recurse:
      - group
      - mode
    - require:
      # Make sure that this state runs after the service is running. This is
      # because we are trying to get the service's ./supervise directory to be
      # owned by this group so factorio admins can manage the service
      # (as per: http://smarden.org/runit/faq.html#user). And the supervise
      # directory will be created for the first time when the service starts.
      - service: {{ pillar.factorio.factorio_service.name }}-running

# Caddy
{{ pillar.caddy.config_dir }}/{{ pillar.factorio.caddy_cfg_file }}:
  file.managed:
    - source: salt://factorio/Caddyfile
    - template: jinja
    - user: {{ pillar.caddy.files.user }}
    - group: {{ pillar.caddy.files.group }}
    - mode: {{ pillar.caddy.files.mode }}
    - makedirs: True
