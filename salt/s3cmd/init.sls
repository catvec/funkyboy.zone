# Installs and configures s3cmd tool.

# Install
s3cmd:
  pkg.installed

# Create user
{{ pillar.s3cmd.group }}-group:
  group.present:
    - name: {{ pillar.s3cmd.group }}

{{ pillar.s3cmd.user }}-user:
  user.present:
    - name: {{ pillar.s3cmd.user }}
    - createhome: False
    - home: /
    - shell: {{ pillar.users_nologin_shell }}
    - groups:
      - {{ pillar.s3cmd.group }}

# Configure
{{ pillar.s3cmd.directory }}:
  file.directory:
    - makedirs: True
    - user: {{ pillar.s3cmd.user }}
    - group: {{ pillar.s3cmd.group }}
    - dir_mode: 750
    - file_mode: 750

{{ pillar.s3cmd.config_file }}:
  file.managed:
    - source: salt://s3cmd/s3cmd-cfg
    - template: jinja
    - user: {{ pillar.s3cmd.user }}
    - group: {{ pillar.s3cmd.group }}
    - mode: 750
    - require:
      - file: {{ pillar.s3cmd.directory }}

{{ pillar.s3cmd.run_s3cmd_script }}:
  file.managed:
    - source: salt://s3cmd/run-s3cmd
    - template: jinja
    - user: {{ pillar.s3cmd.user }}
    - group: {{ pillar.s3cmd.group }}
    - mode: 750
