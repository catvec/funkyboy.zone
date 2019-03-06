# Installs ufw

ufw:
  pkg.installed

{{ pillar.ufw.rules_ip4_file }}:
  file.managed:
    - source: salt://ufw/user.rules
    - mode: 640
    - template: jinja
    - require:
      - pkg: ufw

{{ pillar.ufw.rules_ip6_file }}:
  file.managed:
    - source: salt://ufw/user6.rules
    - mode: 640
    - template: jinja
    - require:
      - pkg: ufw

enable:
  cmd.run:
    - name: ufw enable
    - unless: "ufw status | grep 'Status: active'"
    - require:
      - file: {{ pillar.ufw.rules_ip4_file }}
      - file: {{ pillar.ufw.rules_ip6_file }}

reload:
  cmd.run:
    - name: ufw reload
    - onchanges:
      - file: {{ pillar.ufw.rules_ip4_file }}
      - file: {{ pillar.ufw.rules_ip6_file }}
