{% set dir = '/opt/prometheus-push' %}

prometheus_push_cli:
  # Directory push_script will be located in
  directory: {{ dir }}

  # Script which takes options that allow it to push metrics to any 
  # Push Gateway server
  any_push_script: {{ dir }}/any-prometheus-push.sh

  # Script which runs any_push_script with option values to push metrics to the
  # local Push Gateway server
  local_push_script: /usr/bin/prometheus-push
