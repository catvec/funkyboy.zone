prometheus:
  # Prometheus
  record:
    config_file: /etc/prometheus/prometheus.yml
    rules_file: /etc/prometheus/alert_rules.yml
    svc_file: /etc/sv/prometheus/run
    user: _prometheus
    group: prometheus

  # Alert manager
  alert:
    config_file: /etc/alertmanager.yml
    svc_file: /etc/sv/alertmanager/run
    user: _alertmanager
    group: alertmanager

  # Grafana
  grafana:
    config_file: /etc/grafana/grafana.ini
    grafana_cfg_host: grafana.funkyboy.zone
    hosts: https://grafana.funkyboy.zone
    caddy_cfg: grafana
