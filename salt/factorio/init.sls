# Installs and runs a Factorio server.

{% set svc_dir = '/etc/sv/' + pillar['factorio']['service'] %}
{% set svc_file = svc_dir + '/run' %}
{% set svc_finish_file = svc_dir + '/finish' %}
{% set config_file = pillar['factorio']['directory'] + '/config/server-settings.json' %}

{{ pillar.factorio.group.name }}-group:
  group.present:
    - name: {{ pillar.factorio.group.name }}
    - gid: {{ pillar.factorio.group.id }}

{{ pillar.factorio.user.name }}-user:
  user.present:
    - name: {{ pillar.factorio.user.name }}
    - createhome: False
    - uid: {{ pillar.factorio.user.id }}
    - gid: {{ pillar.factorio.group.id }}
    - groups:
      - docker
    - require:
      - group: {{ pillar.factorio.group.name }}-group

{{ pillar.factorio.directory }}:
  file.directory:
    - user: {{ pillar.factorio.user.name }}
    - group: {{ pillar.factorio.group.name }}
    - file_mode: {{ pillar.factorio.mode }}
    - dir_mode: {{ pillar.factorio.mode }}
    - require:
      - user: {{ pillar.factorio.user.name }}-user
      - group: {{ pillar.factorio.group.name }}-group

{{ config_file }}:
  file.managed:
    - source: salt://factorio/server-settings.json
    - template: jinja
    - user: {{ pillar.factorio.user.name }}
    - group: {{ pillar.factorio.group.name }}
    - mode: {{ pillar.factorio.mode }}
    - require:
      - file: {{ pillar.factorio.directory }}

{{ pillar.factorio.mods_download_directory }}:
  file.recurse:
    - source: salt://factorio/mod_zips
    - user: {{ pillar.factorio.user.name }}
    - group: {{ pillar.factorio.group.name }}
    - file_mode: {{ pillar.factorio.mode }}
    - dir_mode: {{ pillar.factorio.mode }}
    - require:
      - file: {{ pillar.factorio.directory }}

all_mods_zip:
  file.managed:
    - name: {{ pillar.factorio.mods_download_directory }}/all_mods.zip
    - source: salt://factorio/all_mods_zip/all_mods.zip
    - user: {{ pillar.factorio.user.name }}
    - group: {{ pillar.factorio.group.name }}
    - mode: {{ pillar.factorio.mode }}
    - require:
      - file: {{ pillar.factorio.directory }}

{{ pillar.factorio.mods_directory }}:
  file.recurse:
    - source: salt://factorio/mod_zips
    - user: {{ pillar.factorio.user.name }}
    - group: {{ pillar.factorio.group.name }}
    - file_mode: {{ pillar.factorio.mode }}
    - dir_mode: {{ pillar.factorio.mode }}
    - require:
      - file: {{ pillar.factorio.directory }}

{{ svc_dir }}:
  file.directory

{{ svc_file }}:
  file.managed:
    - source: salt://factorio/run
    - mode: 755
    - template: jinja

{{ svc_finish_file }}:
  file.managed:
    - source: salt://factorio/finish
    - mode: 755
    - template: jinja

{{ pillar.factorio.service }}-enabled:
  service.enabled:
    - name: {{ pillar.factorio.service }}
    - require:
      - file: {{ svc_file }}
      - user: {{ pillar.factorio.user.name }}-user
      - file: {{ config_file }}
      - file: {{ pillar.factorio.mods_directory }}

{{ pillar.factorio.service }}-running:
  service.running:
    - name: {{ pillar.factorio.service }}
    - require:
      - service: {{ pillar.factorio.service }}-enabled
    - watch:
      - file: {{ svc_file }}
      - file: {{ config_file }}
      - file: {{ pillar.factorio.mods_directory }}

{{ pillar.caddy.config_dir }}/factorio:
  file.managed:
    - source: salt://factorio/Caddyfile
    - template: jinja
    - user: {{ pillar.caddy.files.user }}
    - group: {{ pillar.caddy.files.group }}
    - mode: {{ pillar.caddy.files.mode }}
