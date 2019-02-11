factorio:
  user:
    name: factorio
    id: 845
  group:
    name: factorio
    id: 845
  mode: 775
  directory: /opt/factorio
  mods_directory: /opt/factorio/mods
  mods_download_directory: /opt/factorio/mods-download
  service: factorio
  docker_image: dtandersen/factorio
  hosts:
    - factorio.funkyboy.zone
  mods_hosts:
    - factorio-mods.funkyboy.zone
  ports:
    game: 34197
    rcon: 27015
