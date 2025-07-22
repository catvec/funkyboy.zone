# Configure SSH
{{ pillar.ssh.server_config_file }}:
  file.managed:
    - source: salt://ssh/sshd_config
    - template: jinja
    - user: {{ pillar.users.root.username }}
    - group: {{ pillar.users.root.group }}
    - mode: 644
    - check_cmd: sudo /usr/sbin/sshd -t -f
