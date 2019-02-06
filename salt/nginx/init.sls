# Installs NGinx.
{% set pkg = 'nginx' %}
{% set svc = 'nginx' %}
{% set conf_f = '/etc/nginx/nginx.conf' %}

{{ pkg }}:
  pkg.installed

{{ conf_f }}:
  file.managed:
    - source: salt://nginx/nginx.conf
    - mode: 644
    - template: jinja
    - require:
      - pkg: {{ pkg }}

{{ pillar.nginx.service_dir }}:
  file.directory:
    - user: {{ pillar.nginx.files.user }}
    - group: {{ pillar.nginx.files.group }}
    - mode: {{ pillar.nginx.files.mode }}
    - recurse:
      - user
      - group
      - mode

{{ pillar.nginx.html_dir }}:
  file.recurse:
    - source: salt://nginx/html
    - user: {{ pillar.nginx.files.user }}
    - group: {{ pillar.nginx.files.group }}
    - dir_mode: {{ pillar.nginx.files.mode }}
    - file_mode: {{ pillar.nginx.files.mode }}

{{ pillar.nginx.config_dir }}:
  file.directory:
    - require:
      - pkg: {{ pkg }}

{{ svc }}-enabled:
  service.enabled:
    - name: {{ svc }}
    - require:
      - file: {{ conf_f }}

{{ svc }}-running:
  service.running:
    - name: {{ svc }}
    - require:
      - service: {{ svc }}-enabled
    - watch:
      - file: {{ conf_f }}
      - file: {{ pillar.nginx.config_dir }}/{{ pillar.file_modes_website.config_file }}
