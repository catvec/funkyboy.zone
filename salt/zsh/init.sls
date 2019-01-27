zsh:
  pkg.installed

{{ pillar.zsh.zprofiled_path }}:
  file.directory:
    - makedirs: true

{{ pillar.zsh.zprofile_path }}:
  file.managed:
    - source: salt://zsh/zshrc
    - mode: 775
    - template: jinja
