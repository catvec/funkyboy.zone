# Installs and configures ufw

# Package
{{ pillar.ufw.package }}:
  pkg.installed

# Configuration
{{ pillar.ufw.rules_ip4_file }}:
  file.managed:
    - source: salt://ufw/user.rules
    - mode: 640
    - template: jinja
    - require:
      - pkg: {{ pillar.ufw.package }}

{{ pillar.ufw.rules_ip6_file }}:
  file.managed:
    - source: salt://ufw/user6.rules
    - mode: 640
    - template: jinja
    - require:
      - pkg: {{ pillar.ufw.package }}

# Service
{{ pillar.ufw.service }}-enabled:
  service.enabled:
    - name: {{ pillar.ufw.service }}
    - require:
      - file: {{ pillar.ufw.rules_ip4_file }}
      - file: {{ pillar.ufw.rules_ip6_file }}

{{ pillar.ufw.service }}-running:
  service.running:
    - name: {{ pillar.ufw.service }}
    - require:
      - service: {{ pillar.ufw.service }}-enabled

reload:
  cmd.run:
    - name: ufw reload
    - onchanges:
      - file: {{ pillar.ufw.rules_ip4_file }}
      - file: {{ pillar.ufw.rules_ip6_file }}
    - require:
      - service: {{ pillar.ufw.service }}-running
