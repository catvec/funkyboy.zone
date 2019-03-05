# Places files for static site goldblum.zone

{{ pillar.caddy.serve_dir }}/{{ pillar.caddy.static_sites.goldblum_zone.www_dir }}:
  file.recurse:
    - source: salt://goldblum-zone-website/www
    - dir_mode: 755
    - file_mode: 755
