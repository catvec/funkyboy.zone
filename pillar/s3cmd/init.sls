{% set dir = '/etc/s3cmd' %}

s3cmd:
  directory: {{ dir }}
  config_file: {{ dir }}/config
  user: s3cmd
  group: s3cmd
  run_s3cmd_script: /usr/bin/run-s3cmd
