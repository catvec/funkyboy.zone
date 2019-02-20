# Install backup crond job.

# Install s3cmd
s3cmd:
  pkg.installed

# User
{{ pillar.backup.group }}-group:
  group.present:
    - name: {{ pillar.backup.group }}

{{ pillar.backup.user }}-user:
  user.present:
    - name: {{ pillar.backup.user }}
    - createhome: False
    - groups:
      - {{ pillar.backup.group }}
    - require:
      - group: {{ pillar.backup.group }}-group

# Make directory
{{ pillar.backup.directory }}:
  file.directory:
    - makedirs: True
    - user: {{ pillar.backup.user }}
    - group: {{ pillar.backup.group }}
    - dir_mode: {{ pillar.backup.mode }}
    - file_mode: {{ pillar.backup.mode }}
    - require:
      - group: {{ pillar.backup.group }}-group
      - user: {{ pillar.backup.group }}-user

# Configure s3cmd
{{ pillar.backup.s3cmd_config }}:
  file.managed:
    - source: salt://backup/s3cmd-cfg
    - template: jinja
    - user: {{ pillar.backup.user }}
    - group: {{ pillar.backup.group }}
    - mode: {{ pillar.backup.mode }}
    - require:
      - file: {{ pillar.backup.directory }}

# Backup script
{{ pillar.backup.script }}:
  file.managed:
    - source: salt://backup/backup.sh
    - user: {{ pillar.backup.user }}
    - group: {{ pillar.backup.group }}
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
