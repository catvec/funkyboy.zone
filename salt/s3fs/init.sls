# Installs s3fs-fuse

{% set pkg = 's3fs-fuse' %}

{{ pkg }}:
  pkg.installed

{{ pillar.s3fs.directory }}:
  file.directory:
    - makedirs: True

{{ pillar.s3fs.passwd_file }}:
  file.managed:
    - source: salt://s3fs/passwd
    - template: jinja
    - mode: 600
    - require:
      - file: {{ pillar.s3fs.directory }}

{{ pillar.s3fs.run_script }}:
  file.managed:
    - source: salt://s3fs/run-s3fs
    - template: jinja
    - mode: 750
