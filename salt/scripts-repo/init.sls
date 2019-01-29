{% set dir = '/opt/scripts' %}
{% set repo = 'https://github.com/Noah-Huppert/scripts.git' %}

{{ dir }}:
  file.directory:
    - makedirs: True
    - dir_mode: 775
    - file_mode: 775
    - recurse:
      - mode

{{ repo }}:
  git.latest:
    - target: {{ dir }}
    - require:
      - file: {{ dir }}

{{ pillar.zsh.zprofiled_path }}/scripts-repo:
  file.managed:
    - source: salt://scripts-repo/zprofile.d/scripts-repo
    - mode: 775
