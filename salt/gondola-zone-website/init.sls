# Places file which will be served at gondola.zone

{{ pillar.caddy.serve_dir }}/{{ pillar.caddy.static_sites.gondola_zone.www_dir }}:
  file.recurse:
    - source: salt://gondola-zone-website/www
    - user: {{ pillar.caddy.files.user }}
    - group: {{ pillar.caddy.files.group }}
    - dir_mode: {{ pillar.caddy.files.mode }}
    - file_mode: {{ pillar.caddy.files.mode }}
