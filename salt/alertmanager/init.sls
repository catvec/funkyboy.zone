# Install Alert Manager, an alerting service used by Prometheus.

{% set pkg = 'alertmanager' %}
{% set svc = 'alertmanager' %}

# Package
{{ pkg }}:
  pkg.installed

# Configuration
{{ pillar.alertmanager.group }}-group:
  group.present:
    - name: {{ pillar.alertmanager.group }}
    - members:
      - {{ pillar.alertmanager.user }}
    - require:
      - pkg: {{ pkg }}

{{ pillar.alertmanager.svc_file }}:
  file.managed:
    - source: salt://alertmanager/run
    - template: jinja
    - makedirs: True
    - mode: 755
    - require:
      - pkg: {{ pkg }}

{{ pillar.alertmanager.svc_log_file }}:
  file.managed:
    - source: salt://alertmanager/log
    - template: jinja
    - makedirs: True
    - mode: 755
    - require:
      - pkg: {{ pkg }}

{{ pillar.alertmanager.config_file }}:
  file.managed:
    - source: salt://alertmanager/alertmanager.yml
    - template: jinja
    - group: {{ pillar.alertmanager.group }}
    - mode: 644
    - require:
      - pkg: {{ pkg }}
      - group: {{ pillar.alertmanager.group }}-group

# Service
{{ svc }}-enabled:
  service.enabled:
    - name: {{ svc }}
    - require:
      - pkg: {{ pkg }}
      - file: {{ pillar.alertmanager.config_file }}
      - file: {{ pillar.alertmanager.svc_file }}
      - file: {{ pillar.alertmanager.svc_log_file }}

{{ svc }}-running:
  service.running:
    - name: {{ svc }}
    - watch:
      - file: {{ pillar.alertmanager.config_file }}
      - file: {{ pillar.alertmanager.svc_file }}
      - file: {{ pillar.alertmanager.svc_log_file }}
    - require:
      - service: {{ svc }}-enabled
      - group: {{ pillar.alertmanager.group }}-group

