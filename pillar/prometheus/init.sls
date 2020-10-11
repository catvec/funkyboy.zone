{% set dir = '/etc/prometheus' %}

prometheus:
  config_file: {{ dir }}/prometheus.yml
  rules_file: {{ dir }}/alert_rules.yml
  svc_file: /etc/sv/prometheus/run
  svc_log_file: /etc/sv/prometheus/log/run
  local_address: "localhost:9090"
  user: _prometheus
  group: prometheus
  hosts: https://prometheus.funkyboy.zone
  caddy_cfg: prometheus
  authorized_users:
    - Noah-Huppert
