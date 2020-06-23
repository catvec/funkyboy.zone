# Downloads the scripts repository onto the server and adds its files to 
# the PATH.

{{ pillar.scripts_repo.repo }}:
  git.latest:
    - target: {{ pillar.scripts_repo.dir }}
    - force_reset: True

{{ pillar.scripts_repo.dir }}:
  file.directory:
    - makedirs: True
    - dir_mode: 775
    - file_mode: 775
    - recurse:
      - mode
    - require:
      - git: {{ pillar.scripts_repo.repo }}

{{ pillar.scripts_repo.repo }}-ignore-file-mods:
  cmd.run:
    - name: git config core.fileMode false
    - unless: git config core.fileMode | grep true
    - cwd: {{ pillar.scripts_repo.dir }}
    - require:
      - git: {{ pillar.scripts_repo.repo }}

{{ pillar.zsh.zprofiled_path }}/scripts-repo:
  file.managed:
    - source: salt://scripts-repo/zprofile.d/scripts-repo
    - mode: 775
