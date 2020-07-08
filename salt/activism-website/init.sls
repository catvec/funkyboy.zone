# Wiki website with general knowledge

{{ pillar.caddy.serve_dir }}/{{ pillar.caddy.static_sites.activism.www_dir }}:
  file.recurse:
    - source: salt://activism-website/www
    - user: {{ pillar.caddy.files.user }}
    - group: {{ pillar.caddy.files.group }}
    - dir_mode: {{ pillar.caddy.files.mode }}
    - file_mode: {{ pillar.caddy.files.mode }}
