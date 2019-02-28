# Installs the rm-container script.
#
# This script is used by services which run a Docker container to stop the 
# Docker container when the service is killed.

{{ pillar.rm_container_script.file }}:
  file.managed:
    - source: salt://rm-container-script/rm-container
    - mode: 755
