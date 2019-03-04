# Downloads the scripts repository onto the server and adds its files to 
# the PATH.

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
    - force_reset: True
    - require:
      - file: {{ dir }}

{{ repo }}-ignore-file-mods:
  cmd.run:
    - name: git config core.fileMode false
    - unless: git config core.fileMode | grep true
    - cwd: {{ dir }}
    - require:
      - git: {{ repo }}

{{ pillar.zsh.zprofiled_path }}/scripts-repo:
  file.managed:
    - source: salt://scripts-repo/zprofile.d/scripts-repo
    - mode: 775
