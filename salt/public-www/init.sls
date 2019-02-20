# Creates shared directory which users can put content in.

{{ pillar.caddy.serve_dir }}/{{ pillar.caddy.static_sites.public_www.www_dir }}:
  file.directory:
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
{{ pillar.caddy.serve_dir }}/{{ pillar.caddy.static_sites.public_www.www_dir }}/{{ user.name }}:
  file.directory:
    - user: {{ user.name }}
    - group: {{ pillar.caddy.files.group }}
    - dir_mode: 755
    - file_mode: 755
    - require:
      - file: {{ pillar.caddy.serve_dir }}/{{ pillar.caddy.static_sites.public_www.www_dir }}
{% endfor %}
