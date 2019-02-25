# Install backup crond job.

# Make directory
{{ pillar.backup.directory }}:
  file.directory:
    - makedirs: True
    - dir_mode: {{ pillar.backup.mode }}
    - file_mode: {{ pillar.backup.mode }}

# Backup script
{{ pillar.backup.lib_backup_script }}:
  file.managed:
    - source: salt://backup/lib-backup.sh
    - mode: {{ pillar.backup.mode }}
    - require:
      - file: {{ pillar.backup.directory }}

{{ pillar.backup.script }}:
  file.managed:
    - source: salt://backup/backup.sh
    - mode: {{ pillar.backup.mode }}
    - require:
      - file: {{ pillar.backup.directory }}

{{ pillar.backup.restore_script }}:
  file.managed:
    - source: salt://backup/restore.sh
    - mode: {{ pillar.backup.mode }}
    - require:
      - file: {{ pillar.backup.directory }}

{{ pillar.backup.run_restore_script }}:
  file.managed:
    - source: salt://backup/run-restore.sh
    - template: jinja
    - mode: {{ pillar.backup.mode }}
    - require:
      - file: {{ pillar.backup.directory }}

# Cron
{{ pillar.backup.cron_run_script }}:
  file.managed:
    - source: salt://backup/cron-run.sh
    - template: jinja
    - mode: 755

{{ pillar.crond.config_dir }}/backup:
  file.managed:
    - source: salt://backup/crontab
    - template: jinja
    - mode: 755
