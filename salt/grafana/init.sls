# Installs and configures Grafana.

{% set pkg = 'grafana' %}
{% set svc = 'grafana' %}

# Package
{{ pkg }}:
  pkg.installed

# Configuration
{{ pillar.grafana.config_file }}:
  file.managed:
    - source: salt://grafana/grafana.ini
    - template: jinja

{{ pillar.caddy.config_dir }}/{{ pillar.grafana.caddy_cfg }}:
  file.managed:
    - source: salt://grafana/Caddyfile
    - template: jinja
    - user: {{ pillar.caddy.files.user }}
    - group: {{ pillar.caddy.files.group }}
    - mode: {{ pillar.caddy.files.mode }}
    - makedirs: True

# Service
# {{ svc }}-enabled:
#   service.enabled:
#     - name: {{ svc }}
#     - require:
#       - pkg: {{ pkg }}

# Disabled until crashes are fixed, probably will not fix and re-make with a new infrastructure overhaul. It keeps crashing bc it cannot make the log dir /var/log/grafana, need to give it its own user and make that dir for it.
{{ svc }}-disabled:
  service.disabled:
    - name: {{ svc }}
    - require:
      - pkg: {{ pkg }}

# {{ svc }}-running:
#   service.running:
#     - name: {{ svc }}
#     - watch:
#       - file: {{ pillar.grafana.config_file }}
#     - require:
#       - service: {{ svc }}-enabled
