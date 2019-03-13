# Creates shared directory which users can put content in.

# Directory
{{ pillar.caddy.serve_dir }}/{{ pillar.caddy.static_sites.public_www.www_dir }}:
  file.directory:
    - makedirs: True
    - dir_mode: 755
    - file_mode: 755

{{ pillar.caddy.serve_dir }}/{{ pillar.caddy.static_sites.public_www.www_dir }}/index.html:
  file.managed:
    - source: salt://public-www/index.html
    - template: jinja
    - user: {{ pillar.caddy.files.user }}
    - group: {{ pillar.caddy.files.group }}
    - mode: {{ pillar.caddy.files.mode }}

{{ pillar.public_www.shortcut_directory }}:
  file.symlink:
    - target: {{ pillar.caddy.serve_dir }}/{{ pillar.caddy.static_sites.public_www.www_dir }}
    - require:
      - file: {{ pillar.caddy.serve_dir }}/{{ pillar.caddy.static_sites.public_www.www_dir }}

{% for user in pillar['users'] %}
{% if user.name not in pillar['public_www']['excluded_users'] %}
{{ pillar.caddy.serve_dir }}/{{ pillar.caddy.static_sites.public_www.www_dir }}/{{ user.name }}:
  file.directory:
    - user: {{ user.name }}
    - group: {{ pillar.caddy.files.group }}
    - dir_mode: 755
    - file_mode: 755
    - require:
      - file: {{ pillar.caddy.serve_dir }}/{{ pillar.caddy.static_sites.public_www.www_dir }}
{% endif %}
{% endfor %}

# Ensure access
{{ pillar.public_www.ensure_access.service_directory }}/run:
  file.managed:
    - source: salt://public-www/ensure-access-run
    - template: jinja
    - mode: 775
    - makedirs: True

{{ pillar.public_www.ensure_access.service }}-enabled:
  service.enabled:
    - name: {{ pillar.public_www.ensure_access.service }}
    - require:
      - file: {{ pillar.public_www.ensure_access.service_directory }}/run

{{ pillar.public_www.ensure_access.service }}-running:
  service.running:
    - name: {{ pillar.public_www.ensure_access.service }}
    - watch:
      - file: {{ pillar.public_www.ensure_access.service_directory }}/run
    - require:
      - service: {{ pillar.public_www.ensure_access.service }}-enabled
