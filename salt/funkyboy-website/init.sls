# Setup Caddy to run funkyboy.zone home page

{{ pillar.caddy.serve_dir }}/{{ pillar.funkyboy_website.www_dir }}:
  file.recurse:
    - source: salt://funkyboy-website/www
    - user: {{ pillar.caddy.files.user }}
    - group: {{ pillar.caddy.files.group }}
    - dir_mode: {{ pillar.caddy.files.mode }}
    - file_mode: {{ pillar.caddy.files.mode }}

{{ pillar.caddy.config_dir }}/{{ pillar.funkyboy_website.config_file }}:
  file.managed:
    - source: salt://funkyboy-website/Caddyfile
    - template: jinja
    - user: {{ pillar.caddy.files.user }}
    - group: {{ pillar.caddy.files.group }}
    - mode: {{ pillar.caddy.files.mode }}
