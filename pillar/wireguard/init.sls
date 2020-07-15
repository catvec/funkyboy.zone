{% set dir = '/etc/wireguard' %}

wireguard:
  # Directories
  package: wireguard
  kernel_module: wireguard
  directory: {{ dir }}
  config_file: {{ dir }}/wg0.conf

  # Interface configuration
  interface:
    # Name of interface
    name: wg0

    # Addresses to assign to the server's interface
    addresses:
      - 192.168.10.1/24

    # Port to listen for Wireguard traffic
    port: 51820

  # Setup script
  setup_script: {{ dir }}/setup.sh

  # Server's public key
  public_key: "7wQ1mXzgFDan86NOSNHgMisL9GfUJQabyhVWzj6w2jw="

  # Peers
  peers:
    # Katla
    - public_key: "ciQ65Q5lbV2aHPW8c+/mchvNk7XwiZwKZ3mLU+1HtWQ="
      ip: 192.168.10.3/24
      keepalive: 25

    # Apollo
    - public_key: "Ae855QtE5mvxgzq6hga87SiwSRSnUr+Dmu6ryfLsvkk="
      ip: 192.168.10.2/24
      keepalive: 25
