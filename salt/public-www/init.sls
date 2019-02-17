# Creates shared directory which users can put content in.

{{ pillar.caddy.serve_dir }}/{{ pillar.caddy.static_sites.public_www.www_dir }}:
  file.directory:
    - dir_mode: 755
    - file_mode: 755

{{ pillar.public_www.shortcut_directory }}:
  file.symlink:
    - target: {{ pillar.caddy.serve_dir }}/{{ pillar.caddy.static_sites.public_www.www_dir }}
    - require:
      - file: {{ pillar.caddy.serve_dir }}/{{ pillar.caddy.static_sites.public_www.www_dir }}

{% for user in pillar['users'] %}
{{ pillar.caddy.serve_dir }}/{{ pillar.caddy.static_sites.public_www.www_dir }}/{{ user.name }}:
  file.directory:
    - owner: {{ user.name }}
    - group: {{ pillar.caddy.files.group }}
    - dir_mode: 750
    - file_mode: 750
    - require:
      - file: {{ pillar.caddy.serve_dir }}/{{ pillar.caddy.static_sites.public_www.www_dir }}
{% endfor %}
