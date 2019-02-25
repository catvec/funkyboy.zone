{% set dir = '/opt/backup' %}

backup:
  # Install
  mode: 775

  directory: {{ dir }}
  lib_backup_script: {{ dir }}/lib-backup.sh
  script: {{ dir }}/backup.sh
  restore_script: {{ dir }}/restore.sh
  cron_run_script: {{ dir }}/cron-run.sh
  run_restore_script: {{ dir }}/run-restore.sh

  # Prometheus metric name
  success_prometheus_metric: backup_success

  # Run argument details
  space: funkyboy-zone-backup
  log_tag: backup

  # Backup targets
  backup_targets:
    - /public
    - /home
    - /opt/factorio/saves
  backup_exclude:
    - '/home/*/.*'
    - '/public/index.html'
