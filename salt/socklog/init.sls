socklog-void:
  pkg.installed

socklog-unix:
  service.enabled:
    - require:
      - pkg: socklog-void

nanoklogd:
  service.enabled:
    - require:
      - pkg: socklog-void
