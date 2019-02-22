# Installs Prometheus Push Gateway and configures it.

# Pull Docker image
{{ pillar.pushgateway.docker_image }}:
  docker_image.present

# Service
{{ pillar.pushgateway.service.directory }}:
  file.directory:
    - makedirs: True

{{ pillar.pushgateway.service.run_file }}:
  file.managed:
    - source: salt://pushgateway/run
    - template: jinja
    - mode: 755
    - require:
      - file: {{ pillar.pushgateway.service.directory }}

{{ pillar.pushgateway.service.finish_file }}:
  file.managed:
    - source: salt://pushgateway/finish
    - template: jinja
    - mode: 755
    - require:
      - file: {{ pillar.pushgateway.service.directory }}

{{ pillar.pushgateway.service.name }}-enabled:
  service.enabled:
    - name: {{ pillar.pushgateway.service.name }}
    - require:
      - file: {{ pillar.pushgateway.service.run_file }}
      - file: {{ pillar.pushgateway.service.finish_file }}

{{ pillar.pushgateway.service.name }}-running:
  service.running:
    - name: {{ pillar.pushgateway.service.name }}
    - watch:
      - file: {{ pillar.pushgateway.service.run_file }}
    - require:
      - {{ pillar.pushgateway.service.name }}-enabled
