# Hosts a website with my workout plan for reference.

{{ pillar.caddy.serve_dir }}/{{ pillar.caddy.static_sites.workout.www_dir }}:
  file.recurse:
    - source: salt://workout-website/www
    - user: {{ pillar.caddy.files.user }}
    - group: {{ pillar.caddy.files.group }}
    - dir_mode: {{ pillar.caddy.files.mode }}
    - file_mode: {{ pillar.caddy.files.mode }}
