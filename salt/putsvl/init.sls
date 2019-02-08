/usr/bin/putsvl:
  file.managed:
    - source: salt://putsvl/putsvl
    - mode: 775
