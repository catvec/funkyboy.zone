# Installs Caddy Server (https://caddyserver.com)

{% set build_dir = '/opt/caddy' %}
{% set build_script = build_dir + '/build.sh' %}
{% set install_check_script = build_dir + '/check-installed.sh' %}
{% set svc_file = '/etc/sv/caddy/run' %}
{% set svc = 'caddy' %}

# Build Caddy
{{ pillar.caddy.files.group }}-group:
  group.present:
    - name: {{ pillar.caddy.files.group }}

{{ pillar.caddy.files.user }}-user:
  user.present:
    - name: {{ pillar.caddy.files.user }}
    - createhome: False
    - groups:
      - {{ pillar.caddy.files.group }}
    - require:
      - group: {{ pillar.caddy.files.group }}-group

{{ build_dir }}:
  file.directory

{{ install_check_script }}:
  file.managed:
    - name: {{ install_check_script }}
    - source: salt://caddy/check-installed.sh
    - mode: 755
    - require:
      - file: {{ build_dir }}

{{ build_script }}-present:
  file.managed:
    - name: {{ build_script }}
    - source: salt://caddy/build.sh
    - mode: 775
    - require:
      - file: {{ build_dir }}
    
{{ build_script }}-run:
  cmd.run:
    - name: {{ build_script }}
    - cwd: {{ build_dir }}
    - unless: {{ install_check_script }} {{ build_dir }}
    - require:
      - file: {{ install_check_script }}
      - file: {{ build_script }}-present
      
{{ svc_file }}:
  file.managed:
    - source: salt://caddy/run
    - makedirs: True
    - template: jinja
    - mode: 775
    - require:
      - cmd: {{ build_script }}-run

# Setup HTTP directory
{{ pillar.caddy.serve_dir }}:
  file.directory:
    - user: {{ pillar.caddy.files.user }}
    - group: {{ pillar.caddy.files.group }}
    - dir_mode: {{ pillar.caddy.files.mode }}
    - file_mode: {{ pillar.caddy.files.mode }}

# Setup SSL certificate directory
{{ pillar.caddy.caddy_path }}:
  file.directory:
    - user: {{ pillar.caddy.files.user }}
    - group: {{ pillar.caddy.files.group }}
    - dir_mode: 770
    - file_mode: 770

# Setup configuration 
{{ pillar.caddy.config_parent_dir }}:
  file.directory:
    - user: {{ pillar.caddy.files.user }}
    - group: {{ pillar.caddy.files.group }}
    - dir_mode: {{ pillar.caddy.files.mode }}
    - file_mode: {{ pillar.caddy.files.mode }}

{{ pillar.caddy.config_dir }}:
  file.directory:
    - user: {{ pillar.caddy.files.user }}
    - group: {{ pillar.caddy.files.group }}
    - dir_mode: {{ pillar.caddy.files.mode }}
    - file_mode: {{ pillar.caddy.files.mode }}
    - require:
      - file: {{ pillar.caddy.config_parent_dir }}

{{ pillar.caddy.config_file }}:
  file.managed:
    - source: salt://caddy/Caddyfile
    - template: jinja
    - user: {{ pillar.caddy.files.user }}
    - group: {{ pillar.caddy.files.group }}
    - mode: {{ pillar.caddy.files.mode }}
    - require:
      - file: {{ pillar.caddy.config_parent_dir }}

# Run service
{{ svc }}-enabled:
  service.enabled:
    - name: {{ svc }}
    - require:
      - file: {{ pillar.caddy.config_dir }}
      - file: {{ pillar.caddy.config_file }}
      - file: {{ pillar.caddy.caddy_path }}
      - file: {{ svc_file }}

{{ svc }}-running:
  service.running:
    - name: {{ svc }}
    - require:
      - service: {{ svc }}-enabled
    - watch:
      - file: {{ pillar.caddy.config_file }}
      - file: {{ pillar.caddy.config_dir }}/*
