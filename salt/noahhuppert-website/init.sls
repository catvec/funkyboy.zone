# Sets up Nginx to host the noahhuppert.com / noahh.io personal website.

{% set repo = 'https://github.com/Noah-Huppert/NoahHuppert.com.git' %}

{{ repo }}:
  git.latest:
    - target: {{ pillar.caddy.serve_dir }}/{{ pillar.caddy.static_sites.noahhuppert.www_parent_dir }}

{{ pillar.caddy.serve_dir }}/{{ pillar.caddy.static_sites.noahhuppert.www_parent_dir }}:
  file.directory:
    - user: {{ pillar.caddy.files.user }}
    - group: {{ pillar.caddy.files.group }}
    - mode: {{ pillar.caddy.files.mode }}
    - recurse:
      - user
      - group
      - mode
    - require:
      - git: {{ repo }}
