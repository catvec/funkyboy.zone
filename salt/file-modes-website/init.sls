# Hosts a website with Nginx which shows useful information about Linux 
# file permissions.

{{ pillar.caddy.serve_dir }}/{{ pillar.file_modes_website.www_dir }}:
  file.recurse:
    - source: salt://file-modes-website/html
    - user: {{ pillar.caddy.files.user }}
    - group: {{ pillar.caddy.files.group }}
    - dir_mode: {{ pillar.caddy.files.mode }}
    - file_mode: {{ pillar.caddy.files.mode }}

{{ pillar.caddy.config_dir }}/{{ pillar.file_modes_website.config_file }}:
  file.managed:
    - source: salt://file-modes-website/Caddyfile
    - template: jinja
    - user: {{ pillar.caddy.files.user }}
    - group: {{ pillar.caddy.files.group }}
    - mode: {{ pillar.caddy.files.mode }}
