# Sets permissions on the /srv directory so that everyone can at least see it.
/srv:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 771
