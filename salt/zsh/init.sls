zsh:
  pkg.installed

{{ pillar.zsh.path }}:
  file.directory:
    - makedirs: True
    - mode: 775

{{ pillar.zsh.zprofiled_path }}:
  file.directory:
    - makedirs: true
    - mode: 775

{{ pillar.zsh.zprofile_path }}:
  file.managed:
    - source: salt://zsh/zshrc
    - mode: 775
    - template: jinja
