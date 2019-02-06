# Sets up Nginx to host the noahhuppert.com / noahh.io personal website.

{% set repo = 'https://github.com/Noah-Huppert/NoahHuppert.com.git' %}
{% set html_dir = pillar['nginx']['html_dir'] + '/' + pillar['noahhuppert_website']['html_dir'] %}

{{ repo }}:
  git.latest:
    - target: {{ html_dir }}

{{ html_dir }}:
  file.directory:
    - user: {{ pillar.nginx.files.user }}
    - group: {{ pillar.nginx.files.group }}
    - mode: {{ pillar.nginx.files.mode }}
    - recurse:
      - user
      - group
      - mode
    - require:
      - git: {{ repo }}

{{ pillar.nginx.config_dir }}/{{ pillar.noahhuppert_website.config_file }}:
  file.managed:
    - source: salt://noahhuppert-website/nginx.conf
    - template: jinja

