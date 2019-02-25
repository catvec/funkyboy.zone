# Install command line tool which pushes metrics to Prometheus via 
# Push Gateway.

{{ pillar.prometheus_push_cli.directory }}:
  file.directory:
    - makedirs: True
    - mode: 755

{{ pillar.prometheus_push_cli.any_push_script }}:
  file.managed:
    - source: salt://prometheus-push-cli/any-prometheus-push.sh
    - mode: 755
    - require:
      - file: {{ pillar.prometheus_push_cli.directory }}

{{ pillar.prometheus_push_cli.local_push_script }}:
  file.managed:
    - source: salt://prometheus-push-cli/prometheus-push
    - template: jinja
    - mode: 755
