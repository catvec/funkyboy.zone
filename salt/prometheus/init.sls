# Install and configures Prometheus.

{% set pkg = 'prometheus' %}
{% set svc = 'prometheus' %}

# Install
{{ pkg }}:
  pkg.installed

# Configure
{{ pillar.prometheus.group }}-group:
  group.present:
    - name: {{ pillar.prometheus.group }}
    - members:
      - {{ pillar.prometheus.user }}
    - require:
      - pkg: {{ pkg }}

{{ pillar.prometheus.svc_file }}:
  file.managed:
    - source: salt://prometheus/run
    - template: jinja
    - mode: 755
    - makedirs: True
    - require:
      - pkg: {{ pkg }}

{{ pillar.prometheus.svc_log_file }}:
  file.managed:
    - source: salt://prometheus/log
    - template: jinja
    - mode: 755
    - makedirs: True
    - require:
      - pkg: {{ pkg }}

{{ pillar.prometheus.config_file }}:
  file.managed:
    - source: salt://prometheus/prometheus.yml
    - template: jinja
    - group: {{ pillar.prometheus.group }}
    - makedirs: True
    - require:
      - group: {{ pillar.prometheus.group }}-group

{{ pillar.prometheus.rules_file }}:
  file.managed:
    - source: salt://prometheus/alert_rules.yml
    - group: {{ pillar.prometheus.group }}
    - mode: 755
    - require:
      - group: {{ pillar.prometheus.group }}-group

# Service
{{ svc }}-enabled:
  service.enabled:
    - name: {{ svc }}
    - require:
      - file: {{ pillar.prometheus.svc_file }}
      - file: {{ pillar.prometheus.svc_log_file }}
      - file: {{ pillar.prometheus.config_file }}  

{{ svc }}-running:
  service.running:
    - name: {{ svc }}
    - watch:
      - file: {{ pillar.prometheus.config_file }}
      - file: {{ pillar.prometheus.rules_file }}
      - file: {{ pillar.prometheus.svc_file }}
      - file: {{ pillar.prometheus.svc_log_file }}
    - require:
      - service: {{ svc }}-enabled
      - file: {{ pillar.prometheus.config_file }}
      - file: {{ pillar.prometheus.rules_file }}
      - file: {{ pillar.prometheus.svc_file }}
      - file: {{ pillar.prometheus.svc_log_file }}

# Caddy
{{ pillar.caddy.config_dir }}/{{ pillar.prometheus.caddy_cfg }}:
  file.managed:
    - source: salt://prometheus/Caddyfile
    - template: jinja
    - user: {{ pillar.caddy.files.user }}
    - group: {{ pillar.caddy.files.group }}
    - mode: {{ pillar.caddy.files.mode }}
    - makedirs: True
