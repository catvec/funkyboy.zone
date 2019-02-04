# Sets up the socklog logging service
#
# Installs socklog and enables its services.
#
# Places the log-service and inject-log-service scripts on the host

{% set pkg = pillar['syslog']['pkg'] %}
{% set sock_svc = pillar['syslog']['sock_svc'] %}
{% set klogd_svc = pillar['syslog']['klogd_svc'] %}

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

{{ klogd_svc}}-enabled:
  service.enabled:
    - name: {{ klogd_svc }}
    - require: 
      - pkg: {{ pkg }}

{{ klogd_svc }}-running:
  service.running:
    - name: {{ klogd_svc }}
    - require:
      - service: {{ klogd_svc }}-enabled

{{ pillar.syslog.inject_log_service_path }}:
  file.managed:
    - source: salt://syslog/inject-log-service
    - mode: 755
