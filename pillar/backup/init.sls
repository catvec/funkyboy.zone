{% set dir = '/opt/backup' %}

backup:
  user: backup
  group: backup
  mode: 775
  directory: {{ dir }}
  script: {{ dir }}/backup.sh
  s3cmd_config: {{ dir }}/s3cmd-cfg
  spaces_region: sfo2
