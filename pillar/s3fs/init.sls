{% set dir = '/opt/s3fs' %}

s3fs:
  directory: {{ dir }}
  passwd_file: {{ dir }}/passwd
  run_script: /usr/bin/run-s3fs
