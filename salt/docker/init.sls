# Install Docker.

{% set pkg = 'docker' %}
{% set svc = 'docker' %}

{{ pkg }}-pkg:
  pkg.installed:
    - name: {{ pkg }}

{{ svc }}-service-enabled:
  service.enabled:
    - name: {{ svc }}
    - require:
      - pkg: {{ pkg }}-pkg

{{ svc }}-service-running:
  service.running:
    - name: {{ svc }}
    - require:
      - service: {{ svc }}-service-enabled
