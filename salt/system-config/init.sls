# Sets up basic system configuration like the time zone.

{{ pillar.system_config.rc_file }}:
  file.managed:
    - source: salt://system-config/rc.conf
