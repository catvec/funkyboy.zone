# Installs the Prometheus Node Exporter https://github.com/prometheus/node_exporter

# Install
{{ pillar.node_exporter.directory }}:
  file.directory:
    - makedirs: True
    - user: {{ pillar.prometheus.user }}
    - group: {{ pillar.prometheus.group }}
    - dir_mode: 755
    - file_mode: 755

{{ pillar.node_exporter.build_script }}-managed:
  file.managed:
    - name: {{ pillar.node_exporter.build_script }}
    - source: salt://node-exporter/build.sh
    - user: {{ pillar.prometheus.user }}
    - group: {{ pillar.prometheus.group }}
    - mode: 755

{{ pillar.node_exporter.build_check_script }}:
  file.managed:
    - source: salt://node-exporter/should-build.sh
    - user: {{ pillar.prometheus.user }}
    - group: {{ pillar.prometheus.group }}
    - mode: 755

{{ pillar.node_exporter.build_script }}-run:
  cmd.run:
    - name: {{ pillar.node_exporter.build_script }}
    - cwd: {{ pillar.node_exporter.directory }}
    - unless: {{ pillar.node_exporter.build_check_script }}
    - require:
      - file: {{ pillar.node_exporter.build_script }}-managed
      - file: {{ pillar.node_exporter.build_check_script }}

# Service
{{ pillar.node_exporter.svc_dir }}:
  file.directory

{{ pillar.node_exporter.svc_file }}:
  file.managed:
    - source: salt://node-exporter/run
    - mode: 755
    - template: jinja
    - require:
      - file: {{ pillar.node_exporter.svc_dir }}

{{ pillar.node_exporter.svc }}-enabled:
  service.enabled:
    - name: {{ pillar.node_exporter.svc }}
    - require: 
      - file: {{ pillar.node_exporter.svc_file }}

{{ pillar.node_exporter.svc }}-running:
  service.running:
    - name: {{ pillar.node_exporter.svc }}
    - watch:
      - file: {{ pillar.node_exporter.svc_file }}
    - require:
      - service: {{ pillar.node_exporter.svc }}-enabled
