# Installs the system guide website files.

{{ pillar.caddy.serve_dir }}/{{ pillar.caddy.static_sites.system_guide.www_dir }}:
  file.directory:
    - makedirs: True
    - dir_mode: 755
    - file_mode: 755

{{ pillar.caddy.serve_dir }}/{{ pillar.caddy.static_sites.system_guide.www_dir }}/index.html:
  file.managed:
    - source: salt://system-guide-website/index.html
    - user: {{ pillar.caddy.files.user }}
    - group: {{ pillar.caddy.files.group }}
    - mode: {{ pillar.caddy.files.mode }}

