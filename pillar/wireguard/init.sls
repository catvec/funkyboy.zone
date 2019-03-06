{% set dir = '/etc/wireguard' %}

wireguard:
  # Directories
  package: wireguard
  kernel_module: wireguard
  directory: {{ dir }}
  config_file: {{ dir }}/wg0.conf

  # Interface configuration
  interface:
    name: wg0
    address: 10.0.0.1/24
  port: 57964

  # Scripts
  setup_script: {{ dir }}/setup.sh
  run_setup_script: {{ dir }}/run-setup.sh

  check_setup_script: {{ dir }}/check-setup.sh
  run_check_setup_script: {{ dir }}/run-check-setup.sh
