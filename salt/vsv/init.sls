# Installs https://github.com/bahamas10/vsv
{% set repo = 'https://github.com/bahamas10/vsv.git' %}

{{ repo }}:
  git.latest:
    - target: {{ pillar.vsv.install_path }}

{{ pillar.vsv.install_path }}:
  file.directory:
    - file_mode: 775
    - dir_mode: 775
    - recurse:
      - mode
    - require:
      - git: {{ repo }}

{{ pillar.vsv.man_path }}:
  file.managed:
    - source: {{ pillar.vsv.install_path }}/man/vsv.8
    - mode: 775
    - require:
      - git: {{ repo }}

makewhatis /usr/local/share/man:
  cmd.run:
    - onchanges:
      - file: {{ pillar.vsv.man_path }}

{{ pillar.zsh.zprofiled_path }}/vsv:
  file.managed:
    - source: salt://vsv/zprofile.d/vsv
    - template: jinja
    - mode: 775
