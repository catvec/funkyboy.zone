base:
  'rpi_vpn':
    # Base system
    - ssh
    - ssh-secret
    - users

    # Security
    - nftables
