# Lab Log
Records of how different collocation resources were setup.

# Table Of Contents
- [Network](#network)
- [Compute](#compute)

# Network
Components:

- [`SwitchA`](#switcha) ([Cisco Catalyst 3650 24PS L](https://www.cisco.com/c/en/us/support/switches/catalyst-3650-series-switches/series.html))

Subnets:

| Name  | VLAN | CIDR          |
|-------|------|---------------|
| mgmt0 | 100  | 10.10.10.1/24 |

Reserved for future use: 10.0.0.0/24 to 10.9.0.0/24. In each subnet the addresses X.X.X.0 to X.X.X.10 (inclusive) are also reserved for future use (.0 and .255 are of course also reserved).

Static IP allocations should start from X.X.X.254 and count down.

Devices:

| Name         | Interface              | IP           |
|--------------|------------------------|--------------|
| NodeA - IPMI | GigabitEthernet 1/0/11 | 10.10.10.254 |

## SwitchA
### Connecting
1. Plug in to the USB Mini terminal port to the switch and another computer
2. Open a serial terminal:
   ```
   screen /dev/ttyACM* 9600
   ```
   Or on Windows use an app like [Tera Term](https://teratermproject.github.io/index-en.html)

### Recovery
#### Entering ROMMON Mode
This is a backup safe mode which lets you run a limited set of commands (Like specifying a new boot image).

1. Turn off the switch
2. Press and hold the mode button on the switch (Circular button in the corner next to the mode LEDs on the front)
3. Turn on the switch
4. Wait a bit before releasing  
   I've found when a message about an interface being down shows it is then a good time to release
5. Confirm you are in ROMMON mode by checking that the prompt shows `switch:`

#### Forgotten Password

[Reference](https://www.cisco.com/c/en/us/support/docs/ios-nx-os-software/ios-xe-16/217045-troubleshoot-password-recovery-in-cisco.html)

If you do not know the password of a switch:

1. Boot into ROMMON mode
2. Tell the switch to ignore any configuration on boot  
   ```cisco
   # ROMMON
   SWITCH_IGNORE_STARTUP_CFG=1
   ```  
3. Boot  
  - Either boot to the currently configured image  
    ```cisco
    # ROMMON
    reset
    ```
  - Or specify an image to boot to  
    ```cisco
    # ROMMON
    boot usbflash0:cat3k_caa-universalk9.x.x.x.SPA.bin
    ```
4. Once booted you should be able to access the switch
5. Unset the start up config ignore command  
   ```cisco
   # enable
   no system ignore startupconfig switch all
   ```
6. Decide what you want to do from here. You can either:
  - Save the blank configuration state
    ```cisco
    # enable
    write memory
    ```
  - Set a new enable secret  
    ```cisco
    # configure terminal
    enable secret <PASSWORD>
    write memory
    ```
  
### Troubleshooting
#### DNS Lookups on Switch Failing
If DNS lookups are failing like so:

```
ping www.cisco.com
...
Unrecognized host or address, or protocol not running
```

Then DNS lookups may be disabled. To enable them run:

```
# configure terminal
ip domain-lookup
```

### Configure
At the end of any session making changes save modifications:

```cisco
# enable
write memory
copy running-config usbflash0:startup-config-YYYY-MM-DD-HH-TT
```

Configuration:

- Hostname
  ```cisco
  # configure terminal
  hostname SwitchA
  ```
- Ensure boot and configuration reading are setup correctly:
  - Ensure startup-config is used
    ```cisco
    # configure terminal
    no system ignore startupconfig switch all
    boot system flash:cat3k_caa-universalk9.16.12.11.SPA.bin
    ```
    If the OS image is not in flash (Check with `dir flash:`) then"
    - [Download the image from the Cisco site](https://software.cisco.com/download/home/284846017/type/282046477/release/Gibraltar-16.12.11)
    - Put the image on a flash drive
    - Plug the flash drive into the switch's USB A port
    - Copy the image from the flash drive to the flash storage:
      ```cisco
      copy usbflash0:<IMAGE NAME> flash:<IMAGE NAME>
      ```
      Then follow the steps to set the image as the default
  - Ensure the config-register is set to `0x102`, run `show version` (`# enable`) and the value will be at the way bottom ([Cisco Docs](https://www.cisco.com/c/en/us/support/docs/routers/10000-series-routers/50421-config-register-use.html))
     ```cisco
     # configure terminal
     config-register 0x102
     ```
- Ensure switch stack number is 1 (This is the number the switch is in a stack)
  - Check the switch number
    ```
    # enable
    show switch
    ```
  - If `Switch#` is not 1 then:
    ```
    # enable
    switch <original #> renumber 1
    ```
    The change will only take effect on reload so:
    ```
    # enable
    write memory
    reload
    ```
    (It is important to reload now because the switch number is used in interface numbers in the commands below)
- Establish layer 3 connectivity to the external internet
  This is required for Cisco smart licesing phone home, as well as external internet access for devices connected to the switch
  - Setup name servers (Cloudflare)
    ```
    # configure terminal
    ip name-server 1.1.1.1 1.0.0.1
    ```
  - Set switch's domain name (Used when generating TLS certificates and such)
    ```
    # configure terminal
    ip domain name funkyboy.zone
    ```
  - Setup ports for external internet access
    - Create a vlan for the ports
      ```
      # configure terminal
      vlan 100
      name external0
      # exit
      ```
    - Configure the vlan to get IPs from DHCP
      ```
      # configure terminal
      interface vlan 100
      ip address dhcp
      # exit
      ```
    - Configure the physical ports to be part of the vlan
      ```
      # configure terminal
      interface range gigabitEthernet 1/0/1-2
      switchport mode access
      switchport access vlan name external0
      # exit
      ```
  - Enable NTP (Required for smart licensing)
    ```
    # configure terminal
    ntp server 129.6.15.28 version 2 prefer
    ```
    This IP is for time-a-g.nist.gov, for more see [the NIST NTP page](https://tf.nist.gov/tf-cgi/servers.cgi)
- Setup smart licensing:
  - Enable smart licensing
    ```
    # configure terminal
    license smart transport callhome
    ```
  - Configure account details:
    ```
    # configure terminal
    call-home
    no http secure server-identity-check
    contact-email-addr <CISCO EMAIL>
    profile CiscoTAC-1
    destination transport-method http
    destination address http https://tools.cisco.com/its/service/oddce/services/DDCEService
    active
    no destination transport-method email
    # exit
    # exit
    ```
    Be sure to replace `<CISCO EMAIL>` with your Cisco email address
  - Enable call home
    ```
    # configure terminal
    service call-home
    ```
  - Follow [the Cisco guide to create a new token in CSSM](https://www.cisco.com/c/en/us/td/docs/switches/lan/catalyst3650/software/release/16-12/configuration_guide/sys_mgmt/b_1612_sys_mgmt_3650_cg/configuring_smart_licensing.html#id_89946)  
    Copy the token and have it handy for the next step
  - Register the device with the new token:
    ```
    # enable
    license smart register idtoken <TOKEN>
    ```
    Be sure to replace `<TOKEN>` with the token's value in CSSM
  - Migrate the perpetual license to smart licensing:
    ```
    # enable
    license smart conversion start
    ```
    You can verify if this process succeeded by going to CSSM > Inventory > Product Instances. The switch's hostname should show up. If you click on it to get more details and expand the item under the "License Usage" section it should sow a license which never expires. You can also see under CSSM > Inventory > Licenses that 1 license is available to use and there are no alerts on your account.
- Enable layer 3 routing  
  ```cisco
  # configure terminal
  ip routing
  ```
- Setup a local user
  - Enable local authentication:
    ```cisco
    # configure terminal
    aaa new-model
    aaa authentication login default local
    ```
  - Enable password encryption:
    ```cisco
    # configure terminal
    service password-encryption
    ```
  - Create a user:
    ```cisco
    # configure terminal
    username admin password <PASSWORD>
    ```
    Replace `<PASSWORD>` with a password

    This username and password will then be used whenever you access the switch or web ui.
- Setup a private management VLAN
  - Create the VLAN
    ```cisco
    # configure terminal
    vlan 200
    name mgmt0
    # exit
    ```
  - Attach interfaces
    ```cisco
    # configure terminal
    interface range gigabitEthernet 1/0/3-12
    switchport mode access
    switchport access vlan name mgmt0
    # exit
    ```
  - Set an IP for the switch in the management VLAN as a gateway
    ```cisco
    # configure terminal
    interface vlan 200
    ip add 10.10.10.1 255.255.255.0
    # exit
    ```
  - Configure a DHCP pool for the VLAN
    ```cisco
    # configure terminal
    ip dhcp excluded-address 10.10.10.1 10.10.10.10
    
    ip dhcp pool mgmt0
    network 10.10.10.0 255.255.255.0
    default-router 10.10.10.1
    # exit
    ```
  - Set static IPs based on mac addresses of harware
    - NodeA IPMI static IP
      ```cisco
      # configure terminal
      ip dhcp pool mgmt0-static
      host 10.10.10.254 255.255.255.0
      client-identifier 0100.2590.d75f.94
      # exit
      ```
- Configure an IPSec VPN
  - Allow VPN traffic:
    ```cisco
    # configure terminal
    access-list 101 permit udp any any eq 500
    access-list 101 permit esp any any
    access-list 101 permit ahp any any
    ```
  - Create a crypto access list:
    ```cisco
    # configure terminal
    ip access-list extended vpn-tunnel
    permit ip 10.10.10.0 0.0.0.255 any
    # exit
    ```
  - Set up a transform set
    ```cisco
    # configure terminal
    crypto ipsec transform-set aes-set0 esp-aes 256 esp-sha-hmac
    mode transport
    # exit
    ```
  - Setup pre-shared key
    ```cisco
    # configure terminal
    crypto isakmp identity address
    crypto isakmp key <KEY> address 0.0.0.0
    crypto isakmp key <KEY> address 10.10.10.1
    ```
    Be sure to replace `<KEY>` with a pre-shared key for the VPN.
  - Create an AES transform policy
    ```cisco
    # configure terminal
    crypto isakmp policy 10
    encryption aes 256
    authentication pre-share
    hash sha256
    lifetime 180
    group 14
    ```
  - Setup the address pool for clients:
    ```cisco
    # configure terminal
    ip local pool vpn-client-pool0 10.10.20.0 10.10.20.255
    crypto isakmp client configuration address-pool local vpn-client-pool0
    ```
  - Set up a dynamic crypto map:
    ```cisco
    # configure terminal
    crypto dynamic-map vpn-tunnel-dynamic-map0 1
    set transform-set aes-set0
    set pfs group19
    # exit
    ```
  - Set up a static crypto map:
    ```cisco
    # configure terminal
    crypto map vpn-tunnel-static-map0 1 ipsec-isakmp dynamic vpn-tunnel-dynamic-map0
    ```
  - Apply the crypto map to the external interface
    ```cisco
    # configure terminal
    interface vlan 100
    crypto map vpn-tunnel-static-map0
    # exit
    ```
---
OLD
- Management VLAN
  - Create VLAN
    - Management
      ```cisco
      # configure terminal
      vlan 200
      name mgmt0
      # exit
      ```
    - Public traffic
      ```cisco
      # configure terminal
      vlan 300
      name public0
      # exit
      ```
  - Attach interfaces
    - Management
      ```cisco
      # configure terminal
      interface range gigabitEthernet 1/0/3-12
      switchport mode access
      switchport access vlan name mgmt0
      # exit
      ```
    - Public traffic
      ```cisco
      # configure terminal
      interface range gigabitEthernet 1/0/13-24
      switchport mode access
      switchport access vlan name public0
      # exit
      ```
  - Configure IPs
    - Management
      - Switch
        ```cisco
        # configure terminal
        interface vlan 200
        ip add 10.10.10.1 255.255.255.0
        # exit
        ```
      - DHCP pool
        ```cisco
        # configure terminal
        ip dhcp excluded-address 10.10.10.1 10.10.10.10
        
        ip dhcp pool mgmt0
        network 10.10.10.0 255.255.255.0
        default-router 10.10.10.1
        dns-server 8.8.8.8
        # exit
        ```
        ```cisco
        service dhcp mgmt0
        ```
      - NodeA IPMI static IP
        ```cisco
        # configure terminal
        ip dhcp pool mgmt0-static
        host 10.10.10.254 255.255.255.0
        client-identifier 0100.2590.d75f.94
        ```
    - Public traffic
      - Switch
        ```cisco
        # configure terminal
        interface vlan 300
        ip add 10.10.20.1 255.255.255.0
        ```
      - DHCP pool
        ```cisco
        # configure terminal
        ip dhcp excluded-address 10.10.20.1 10.10.20.10
        
        ip dhcp pool public0
        network 10.10.20.0 255.255.255.0
        default-router 10.10.20.1
        dns-server 8.8.8.8
        ```
      - NodeA static IP
        ```cisco
        # configure terminal
        ip dhcp pool public0-static
        host 10.10.20.254 255.255.255.0
        client-identifier 0100.2590.d761.16
        ```
    
# Compute
Components:

- [NodeA](#nodea)

## NodeA
### Connecting
Connect the IPMI ethernet port to the switch. Ensure the switch is running a DHCP server so the node gets an IP.

Then connect your laptop to the same VLAN on the switch and navigate to the IPMI port's IP in your browser. 

The default login is:

| Username | Password |
|----------|----------|
| `ADMIN`  | `ADMIN`  |

### Configuration

- Activate license for IPMI
  - In the IPMI web console go to: Maintenance > BIOS Update
  - Enter the product key
