# Clones the Noah-Huppert/linux-install repo

{{ pillar.linux_install_repo.repo }}:
  git.latest:
    - target: {{ pillar.linux_install_repo.directory }}
    - force_reset: True

{{ pillar.linux_install_repo.repo }}-ignore-file-mods:
  cmd.run:
    - name: git config core.fileMode false
    - unless: git config core.fileMode | grep true
    - cwd: {{ pillar.linux_install_repo.directory }}
    - require:
      - git: {{ pillar.linux_install_repo.repo }}


{{ pillar.linux_install_repo.directory }}:
  file.directory:
    - mode: 777
    - recurse:
      - mode
    - require:
      - git: {{ pillar.linux_install_repo.repo }}
