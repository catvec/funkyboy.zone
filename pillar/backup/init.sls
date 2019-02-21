{% set dir = '/opt/backup' %}

backup:
  user: backup
  group: backup
  mode: 775
  directory: {{ dir }}
  script: {{ dir }}/backup.sh
  cron_run_script: {{ dir }}/cron-run.sh
  s3cmd_config: {{ dir }}/s3cmd-cfg
  space: funkyboy-zone-backup
  spaces_region: sfo2
  success_status_file: {{ dir }}/successfully-ran
  log_tag: backup
  backup_targets:
    - /public
    - /home
  backup_exclude:
    - '/home/*/.*'
