# Installs NGinx.
{% set pkg = 'nginx' %}
{% set svc = 'nginx' %}

{{ pkg }}:
  pkg.installed

{{ svc }}-enabled:
  service.enabled:
    - name: {{ svc }}
    - require:
      - pkg: {{ pkg }}

{{ svc }}-running:
  service.running:
    - name: {{ svc }}
    - require:
      - service: {{ svc }}-enabled


