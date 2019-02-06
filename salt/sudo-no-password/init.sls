# Configures the sudoers file to allow users in the wheel group to use sudo 
# without entering their password.

/etc/sudoers.d/sudo-no-password:
  file.managed:
    - source: salt://sudo-no-password/sudoers.d/sudo-no-password
