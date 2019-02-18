# Install and configures Prometheus.

{% set record_pkg = 'prometheus' %}
{% set alert_pkg = 'alertmanager' %}
{% set grafana_pkg = 'grafana' %}

{% set record_svc = 'prometheus' %}
{% set alert_svc = 'alertmanager' %}
{% set grafana_svc = 'grafana' %}

# Prometheus
{{ record_pkg }}:
  pkg.installed

{{ pillar.prometheus.record.group }}-group:
  group.present:
    - name: {{ pillar.prometheus.record.group }}
    - members:
      - {{ pillar.prometheus.record.user }}
    - require:
      - pkg: {{ record_pkg }}

{{ pillar.prometheus.record.svc_file }}:
  file.managed:
    - source: salt://prometheus/prometheus_run
    - template: jinja
    - require:
      - pkg: {{ record_pkg }}

{{ pillar.prometheus.record.config_file }}:
  file.managed:
    - source: salt://prometheus/prometheus.yml
    - group: {{ pillar.prometheus.record.group }}
    - mode: 755
    - require:
      - group: {{ pillar.prometheus.record.group }}-group

{{ pillar.prometheus.record.rules_file }}:
  file.managed:
    - source: salt://prometheus/alert_rules.yml
    - group: {{ pillar.prometheus.record.group }}
    - mode: 755
    - require:
      - group: {{ pillar.prometheus.record.group }}-group

{{ record_svc }}-enabled:
  service.enabled:
    - name: {{ record_svc }}
    - require:
      - file: {{ pillar.prometheus.record.svc_file }}

{{ record_svc }}-running:
  service.running:
    - name: {{ record_svc }}
    - watch:
      - file: {{ pillar.prometheus.record.config_file }}
      - file: {{ pillar.prometheus.record.rules_file }}
    - require:
      - service: {{ record_svc }}-enabled
      - service: {{ alert_svc }}-running
      - file: {{ pillar.prometheus.record.config_file }}
      - file: {{ pillar.prometheus.record.rules_file }}

# Alertmanager
{{ alert_pkg }}:
  pkg.installed

{{ pillar.prometheus.alert.group }}-group:
  group.present:
    - name: {{ pillar.prometheus.alert.group }}
    - members:
      - {{ pillar.prometheus.alert.user }}
    - require:
      - pkg: {{ alert_pkg }}

{{ pillar.prometheus.alert.svc_file }}:
  file.managed:
    - source: salt://prometheus/alertmanager_run
    - template: jinja
    - require:
      - pkg: {{ alert_pkg }}

{{ pillar.prometheus.alert.config_file }}:
  file.managed:
    - source: salt://prometheus/alertmanager.yml
    - group: {{ pillar.prometheus.alert.group }}
    - mode: 755
    - require:
      - group: {{ pillar.prometheus.alert.group }}-group

{{ alert_svc }}-enabled:
  service.enabled:
    - name: {{ alert_svc }}
    - require:
      - pkg: {{ alert_pkg }}

{{ alert_svc }}-running:
  service.running:
    - name: {{ alert_svc }}
    - watch:
      - file: {{ pillar.prometheus.alert.config_file }}
    - require:
      - service: {{ alert_svc }}-enabled
      - group: {{ pillar.prometheus.alert.group }}-group

# Grafana
{{ grafana_pkg }}:
  pkg.installed

{{ pillar.prometheus.grafana.config_file }}:
  file.managed:
    - source: salt://prometheus/grafana.ini
    - template: jinja

{{ pillar.caddy.config_dir }}/{{ pillar.prometheus.grafana.caddy_cfg }}:
  file.managed:
    - source: salt://prometheus/Caddyfile
    - template: jinja
    - user: {{ pillar.caddy.files.user }}
    - group: {{ pillar.caddy.files.group }}
    - mode: {{ pillar.caddy.files.mode }}

{{ grafana_svc }}-enabled:
  service.enabled:
    - name: {{ grafana_svc }}
    - require:
      - pkg: {{ grafana_pkg }}

{{ grafana_svc }}-running:
  service.running:
    - name: {{ grafana_svc }}
    - watch:
      - file: {{ pillar.prometheus.grafana.config_file }}
    - require:
      - service: {{ grafana_svc }}-enabled
      - service: {{ record_svc }}-running
