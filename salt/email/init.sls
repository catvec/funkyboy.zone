# Installs postfix for a send only email setup.

{% set svc = 'postfix' %}

mailx:
  pkg.installed

postfix:
  pkg.installed

{{ pillar.email.config_file }}:
  file.managed:
    - mode: 644

{{ pillar.email.aliases_file }}:
  file.managed:
    - mode: 644
    - template: jinja

newaliases:
  cmd.run:
    - onchanges:
      - file: {{ pillar.email.aliases_file }}

{{ svc }}-enabled:
  service.enabled:
    - name: {{ svc }}
    - require:
      - file: {{ pillar.email.config_file }}
      - file: {{ pillar.email.aliases_file }}

{{ svc }}-running:
  service.running:
    - name: {{ svc }}
    - watch:
      - file: {{ pillar.email.config_file }}
    - require:
      - service: {{ svc }}-enabled
