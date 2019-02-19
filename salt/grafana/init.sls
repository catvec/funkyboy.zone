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

# Service
{{ svc }}-enabled:
  service.enabled:
    - name: {{ svc }}
    - require:
      - pkg: {{ pkg }}

{{ svc }}-running:
  service.running:
    - name: {{ svc }}
    - watch:
      - file: {{ pillar.grafana.config_file }}
    - require:
      - service: {{ svc }}-enabled
