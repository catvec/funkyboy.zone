{% set mode = 775 %}

{{ pillar.void_scripts_dir }}:
  file.recurse:
    - source: salt://void-scripts/bin/
    - dir_mode: {{ mode }}
    - file_mode: {{ mode }}

{{ pillar.zsh.zprofiled_path }}/void-scripts:
  file.managed:
    - source: salt://void-scripts/zprofile.d/void-scripts
    - mode: 775
    - template: jinja
