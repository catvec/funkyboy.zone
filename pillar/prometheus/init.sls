prometheus:
  config_file: /etc/prometheus/prometheus.yml
  rules_file: /etc/prometheus/alert_rules.yml
  svc_file: /etc/sv/prometheus/run
  user: _prometheus
  group: prometheus
