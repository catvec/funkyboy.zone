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
    - user: nginx
    - group: nginx
    - mode: 775
    - recurse:
      - user
      - group
      - mode

{{ pillar.nginx.service_dir }}/{{ pillar.nginx.html_dir }}:
  file.recurse:
    - source: salt://nginx/www
    - require:
      - file: {{ pillar.nginx.service_dir }}

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
