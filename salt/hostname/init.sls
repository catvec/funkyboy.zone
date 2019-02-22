# Sets the system's hostname

{{ pillar.hostname.file }}:
  file.managed:
    - contents: {{ pillar.hostname.value }}
    - mode: 755
