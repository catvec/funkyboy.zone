# Installs Caddy Server (https://caddyserver.com)

# Build
{{ pillar.caddy.build_script }}:
  file.managed:
    - source: salt://caddy/build.sh
    - template: jinja
    - makedirs: True
    - mode: 755

{{ pillar.caddy.build_main }}:
  file.managed:
    - source: salt://caddy/main.go
    - template: jinja
    - makedirs: True

build_caddy:
  cmd.run:
    - name: {{ pillar.caddy.build_script }}
    - stateful: True
    - creates: {{ pillar.caddy.install_file }}
    - onchanges:
      - file: {{ pillar.caddy.build_main }}
    - require:
      - file: {{ pillar.caddy.build_script }}
      - file: {{ pillar.caddy.build_main }}

{{ pillar.caddy.config_file }}:
  file.managed:
    - source: salt://caddy/Caddyfile
    - template: jinja
    - makedirs: True

# Service
{{ pillar.caddy.svc_file }}:
  file.managed:
    - source: salt://caddy/run
    - template: jinja
    - makedirs: True
    - require:
      - file: {{ pillar.caddy.config_file }}
      
{{ pillar.caddy.svc }}-enabled:
  service.enabled:
    - name: {{ pillar.caddy.svc }}
    - require:
        - cmd: build_caddy
        - file: {{ pillar.caddy.svc_file }}

{{ pillar.caddy.svc }}-running:
  service.running:
    - name: {{ pillar.caddy.svc }}
    - require:
      - service: {{ pillar.caddy.svc }}-enabled
