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

  # Setup script
  setup_script: {{ dir }}/setup.sh

  # Public key website
  public_key: "7wQ1mXzgFDan86NOSNHgMisL9GfUJQabyhVWzj6w2jw="

  # Peers
  peers:
    # Katla
    - public_key: "ciQ65Q5lbV2aHPW8c+/mchvNk7XwiZwKZ3mLU+1HtWQ="
      ips:
        - 10.0.0.0/24
      keepalive: 25

    # Apollo
    - public_key: "Ae855QtE5mvxgzq6hga87SiwSRSnUr+Dmu6ryfLsvkk="
      ips:
        - 10.0.0.0/24
      keepalive: 25
