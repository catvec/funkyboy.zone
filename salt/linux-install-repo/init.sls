# Clones the Noah-Huppert/linux-install repo

{{ pillar.linux_install_repo.repo }}:
  git.latest:
    - target: {{ pillar.linux_install_repo.directory }}

{{ pillar.linux_install_repo.directory }}:
  file.directory:
    - mode: 777
    - recurse:
      - mode
    - require:
      - git: {{ pillar.linux_install_repo.repo }}
