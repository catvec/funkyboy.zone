{% set pkg = 'socklog-void' %}
{% set sock_svc = 'socklog-unix' %}
{% set logd_svc = 'nanoklogd' %}

{{ pkg }}:
  pkg.installed

{{ sock_svc}}-enabled:
  service.enabled:
    - name: {{ sock_svc }}
    - require:
      - pkg: {{ pkg }}

{{ sock_svc }}-running:
  service.running:
    - name: {{ sock_svc }}
    - require:
      - service: {{ sock_svc }}-enabled

{{ logd_svc}}-enabled:
  service.enabled:
    - name: {{ logd_svc }}
    - require: 
      - pkg: {{ pkg }}

{{ logd_svc }}-running:
  service.running:
    - name: {{ logd_svc }}
    - require:
      - service: {{ logd_svc }}-enabled
