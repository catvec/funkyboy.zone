# RPI VPN
Raspberry PI VPN.

# Table Of Contents
- [Install Instructions](#install-instructions)

# Install Instructions
1. Install the [Raspberry Pi Imager tool](https://www.raspberrypi.com/software/)
2. Run the Raspberry Pi imager tool
  - Choose the device model of `Raspberry Pi 3`
  - Select the OS image of `Raspberry PI OS LITE (64-bit)`
  - Select your SD card in the list for storage
  - Edit settings:
    - General
      - Hostname: `jump-box-a`
      - Set username and password:
        - Username: `admin`
        - Password: Something long and secret
      - Don't configure a wireless LAN
      - Set locale settings:
        - Time zone: `America/New_York`
        - Keyboard layout: `us`
    - Services
      - Enable SSH
      - Allow public-key authentication only
      - Then add your public key
    - Options
      - Eject media when finished
      - Disable telemetry
