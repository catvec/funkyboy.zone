{% set svc = 'node-exporter' %}
{% set svc_dir = '/etc/sv/' + svc %}

node_exporter:
  directory: /opt/node-exporter
  build_script: /opt/node-exporter/build.sh
  build_check_script: /opt/node-exporter/should-build.sh
  svc: {{ svc }}
  svc_dir: {{ svc_dir }}
  svc_file: {{ svc_dir }}/run
  metrics_host: 'localhost:9100'
