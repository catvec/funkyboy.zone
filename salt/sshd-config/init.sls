# Configures the SSH daemon to disallow logins from root.

{% set file = '/etc/ssh/sshd_config' %}

{{ file }}:
  file.managed:
    - source: salt://sshd-config/sshd_config
    - mode: 644

sshd:
  service.running:
    - watch: 
      - file: {{ file }}
