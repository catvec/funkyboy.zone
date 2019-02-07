# Hosts a website with Nginx which shows useful information about Linux 
# file permissions.

{{ pillar.caddy.serve_dir }}/{{ pillar.caddy.static_sites.file_modes.www_dir }}:
  file.recurse:
    - source: salt://file-modes-website/html
    - user: {{ pillar.caddy.files.user }}
    - group: {{ pillar.caddy.files.group }}
    - dir_mode: {{ pillar.caddy.files.mode }}
    - file_mode: {{ pillar.caddy.files.mode }}
