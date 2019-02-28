{% set dir = '/opt/factorio' %}

{% set factorio_svc_name = 'factorio' %}
{% set factorio_svc_dir = '/etc/sv/' + factorio_svc_name %}

{% set mods_fs_svc_name = 'factorio-mods-s3fs' %}
{% set mods_fs_svc_dir = '/etc/sv/' + mods_fs_svc_name %}

{% set factorio_cfg_dir = dir + '/config' %}

{% set mods_dir = dir + '/mods' %}

factorio:
  # User
  # User which runs factorio server
  user:
    name: factorio
    id: 845

  # Factorio user group
  group:
    name: factorio
    id: 845

  mods_access_group:
    name: factorio-mods
    id: 846

  # Mode of files to place
  mode: 775

  # Factorio server
  # Directory place factorio files in
  directory: {{ dir }}

  # Factorio service details
  factorio_service:
    name: {{ factorio_svc_name }}
    directory: {{ factorio_svc_dir }}
    run_file: {{ factorio_svc_dir }}/run
    finish_file: {{ factorio_svc_dir }}/finish

  # Factorio configuration details:
  factorio_config:
    directory: {{ factorio_cfg_dir }}
    file: {{ factorio_cfg_dir }}/server-settings.json

  # Factorio saves directory
  saves_directory: {{ dir }}/saves

  # Factorio server docker image 
  docker_image: dtandersen/factorio:0.17
  docker_container_name: factorio

  # Hosts which factorio server will be accessible by
  hosts:
    - factorio.funkyboy.zone

  # Ports factorio server uses
  ports:
    # UDP game port
    game: 34197

    # TCP remove connection port
    rcon: 27015

  # Mods server
  # Directory factorio mods are stored in
  mods_directory: {{ mods_dir }}
  mod_list_f: {{ mods_dir }}/mod-list.json

  # Hosts which factorio mods can be downloaded at
  mods_hosts:
    - factorio-mods.funkyboy.zone 

  # Name of caddy configuration file
  caddy_cfg_file: factorio

  # s3 file system configuration for mods directory
  check_mods_script: {{ dir }}/check-mods.sh
  run_check_mods_script: {{ dir }}/run-check-mods.sh
  mount_mods_script: {{ dir }}/mount-mods.sh
  run_mount_mods_script: {{ dir }}/run-mount-mods.sh

  # Factorio mods Digital Ocean Space
  mods_space: factorio-mods
