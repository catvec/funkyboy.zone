/opt/scripts:
  file.directory:
    - makedirs: True
    - mode: 557

https://github.com/Noah-Huppert/scripts.git:
  git.latest:
    - target: /opt/scripts
    - require:
      - file: /opt/scripts

{{ pillar.zsh.zprofiled_path }}/scripts-repo:
  file.managed:
    - source: salt://scripts-repo/zprofile.d/scripts-repo
    - mode: 775
