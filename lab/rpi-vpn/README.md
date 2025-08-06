# RPI VPN
Raspberry PI VPN.

# Table Of Contents
- [Install Instructions](#install-instructions)
- [Ways to Brick](#ways-to-brick)
- [Test Suite](#test-suite)

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
3. Use [Salt SSH](https://docs.saltproject.io/en/latest/topics/ssh/index.html) to configure the rest:
   - First ensure the [`salt-run/conf/roster.yaml`](./salt-run/conf/roster.yaml) file has the correct `host` value
   - Generate an SSH key to manage the Raspberry Pi, then copy it to the device:
     - Generate the key:
       ```
       ssh-keygen -t ed25519 -f ../../secret/lab/rpi-vpn/pki/management_key
       ```
     - Copy the key to the Pi:
       ```
       ssh-copy-id -i ../../secret/lab/rpi-vpn/pki/management_key admin@${RPI_HOST}
       ```
4. Run Salt for the first time with a custom roster file:
   > This is needed because SSH will still be using the default SSH port (`22`):
   - Make a temporary file like `bootstrap-roster.yaml`:
     ```
     rpi_vpn:
       host: <IP>
       user: admin
       port: 22
     ```
   - Run `salt-ssh` with the `--roster-file` argument:
     ```
     ./scripts/salt-ssh --roster-file ./bootstrap-roster.yaml state.apply
     ```
   - Then SSH in to the Pi and run the following to restart the SSH server:
     ```
     sudo systemctl reload sshd
     ```
     You must run this command whenever a config file change is made. We don't want to run this command automatically in case it bricks our installation remotely.
 
# Ways to Brick
This is a list of ways you can brick the installation. Usually resulting in needing physical access to the Raspberry Pi. So try not to do these things:

- Removing your SSH public key from `/home/admin/.ssh/authorized_keys`  
  Since the Raspberry Pi has SSH password authentication disabled the only way to access it is via public key authentication. If you remove your key from the authorized keys file then you cannot log in at all.  
  
  To fix this you need to get the Raspberry Pi SD card, mount it on your computer, and manually add your public key back to the authorized keys file.

# Test Suite
See [`tests/`](./tests) for a Vagrant simulation of the VPN and some tests.
