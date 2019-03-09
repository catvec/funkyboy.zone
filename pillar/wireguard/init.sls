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
    addresses:
      - 10.0.0.1/24
    port: 51820

  # Scripts
  setup_script: {{ dir }}/setup.sh
  run_setup_script: {{ dir }}/run-setup.sh

  check_setup_script: {{ dir }}/check-setup.sh
  run_check_setup_script: {{ dir }}/run-check-setup.sh

  # Public key website
  public_key: "7wQ1mXzgFDan86NOSNHgMisL9GfUJQabyhVWzj6w2jw="

  # Peers
  peers:
    - public_key: "ciQ65Q5lbV2aHPW8c+/mchvNk7XwiZwKZ3mLU+1HtWQ=" # Katla
      ips:
        - 10.0.0.0/24
      keepalive: 25
