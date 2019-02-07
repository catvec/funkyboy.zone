# Sets up Nginx to host the noahhuppert.com / noahh.io personal website.

{% set repo = 'https://github.com/Noah-Huppert/NoahHuppert.com.git' %}

{{ repo }}:
  git.latest:
    - target: {{ pillar.caddy.serve_dir }}/{{ pillar.noahhuppert_website.www_dir }}
