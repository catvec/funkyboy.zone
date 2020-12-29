# Flight simulator flight website.

{{ pillar.caddy.serve_dir }}/{{ pillar.caddy.static_sites.turtle_wiki.www_dir }}:
  file.recurse:
    - source: salt://turtle-wiki-website/www
    - user: {{ pillar.caddy.files.user }}
    - group: {{ pillar.caddy.files.group }}
    - dir_mode: {{ pillar.caddy.files.mode }}
    - file_mode: {{ pillar.caddy.files.mode }}
