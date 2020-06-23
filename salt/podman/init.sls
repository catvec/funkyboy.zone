# Installs Podman.

{{ pillar.podman.pkg }}:
  pkg.installed

{{ pillar.podman.registries_file }}:
  file.managed:
    - source: salt://podman/registries.conf
    - mode: 644
    - makedirs: True
