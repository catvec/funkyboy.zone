{% set dir = '/opt/backup' %}

backup:
  # Install
  user: backup
  group: backup
  mode: 775

  directory: {{ dir }}
  script: {{ dir }}/backup.sh
  restore_script: {{ dir }}/restore.sh
  cron_run_script: {{ dir }}/cron-run.sh
  s3cmd_config: {{ dir }}/s3cmd-cfg

  # Run argument details
  space: funkyboy-zone-backup
  spaces_region: sfo2
  success_status_file: {{ dir }}/successfully-ran
  log_tag: backup

  # Backup targets
  backup_targets:
    - /public
    - /home
  backup_exclude:
    - '/home/*/.*'
