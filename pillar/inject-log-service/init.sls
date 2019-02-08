{% set dir = '/opt/inject-log-service' %}

inject_log_service:
  script_dir: {{ dir }}
  inject_script_file: {{ dir }}/inject-log-service
  check_script_file: {{ dir }}/check-log-service-injected
