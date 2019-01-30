/etc/sudoers.d/sudo-no-password:
  file.managed:
    - source: salt://sudo-no-password/sudoers.d/sudo-no-password
