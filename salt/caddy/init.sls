# Installs Caddy Server (https://caddyserver.com)

{% set build_dir = '/opt/caddy' %}
{% set build_script = build_dir + '/build.sh' %}
{% set svc_file = '/etc/sv/caddy/run' %}
{% set svc = 'caddy' %}

# Build Caddy
{{ build_dir }}:
  file.directory

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
    - require:
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

# Setup configuration 
{{ pillar.caddy.config_dir }}:
  file.directory:
    - user: {{ pillar.caddy.files.user }}
    - group: {{ pillar.caddy.files.group }}
    - dir_mode: {{ pillar.caddy.files.mode }}
    - file_mode: {{ pillar.caddy.files.mode }}

{{ pillar.caddy.config_file }}:
  file.managed:
    - source: salt://caddy/Caddyfile
    - template: jinja
    - user: {{ pillar.caddy.files.user }}
    - group: {{ pillar.caddy.files.group }}
    - dir_mode: {{ pillar.caddy.files.mode }}
    - file_mode: {{ pillar.caddy.files.mode }}

# Run service
{{ svc }}-enabled:
  service.enabled:
    - name: {{ svc }}
    - require:
      - file: {{ pillar.caddy.config_dir }}
      - file: {{ pillar.caddy.config_file }}
      - file: {{ svc_file }}

{{ svc }}-running:
  service.running:
    - name: {{ svc }}
    - require:
      - service: {{ svc }}-enabled
    - watch:
      - file: {{ pillar.caddy.config_file }}
      - file: {{ pillar.caddy.config_dir }}/*
