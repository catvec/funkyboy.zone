# Setup Caddy to run funkyboy.zone home page

{{ pillar.caddy.serve_dir }}/{{ pillar.caddy.static_sites.funkyboy.www_dir }}:
  file.recurse:
    - source: salt://funkyboy-website/www
    - user: {{ pillar.caddy.files.user }}
    - group: {{ pillar.caddy.files.group }}
    - dir_mode: {{ pillar.caddy.files.mode }}
    - file_mode: {{ pillar.caddy.files.mode }}
