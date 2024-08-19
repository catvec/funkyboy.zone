# Lab Log
Records of how different collocation resources were setup.

# Table Of Contents
- [Network](#network)
- [Compute](#compute)

# Network
Components:

- [`Switch0`](#switch0) ([Cisco Catalyst 3650 24PS L](https://www.cisco.com/c/en/us/support/switches/catalyst-3650-series-switches/series.html))

Subnets:

| Name  | VLAN | CIDR          |
|-------|------|---------------|
| mgmt0 | 100  | 10.10.10.1/24 |

Reserved for future use: 10.0.0.0/24 to 10.9.0.0/24.

Devices:

| Name  | Interface              | IP          |
|-------|------------------------|-------------|
| Node0 | GigabitEthernet 1/0/11 | 10.10.10.11 |

## Switch0
### Connecting
1. Plug in to the USB Mini terminal port to the switch and another computer
2. Open a serial terminal:
   ```
   screen /dev/ttyACM* 9600
   ```

### Configure
- ```cisco
  # Switch0(config)#
  no ip domain-lookup
  ```
   Stop DNS lookup on wrong command
- Hostname
  ```cisco
  # Switch0(config)
  hostname Switch0
  ```
- Management VLAN
  - Create VLAN
    ```cisco
    # Switch0(config)
    vlan 100
    name mgmt0
    ```
  - Attach interfaces
    ```cisco
    # Switch0(config)
    interface range gigabitEthernet 1/0/3-12
    switchport mode access
    switchport access vlan name mgmt0
    ```
  - Configure IPs
    ~~Manual IP addressing.~~
    - Switch
      ```cisco
      # Switch0(config)
      interface vlan 100
      ip add 10.10.10.1 255.255.255.0
      ```
    - Node0 interface
      ```cisco
      # Switch0(config)
      interface GigabitEthernet 1/0/11
      description Node0
      ```
    - DHCP pool
      ```cisco
      # Switch0(config)
      ip dhcp pool mgmt0
      network 10.10.10.0 255.255.255.0
      default-router 10.10.10.1
      dns-server 8.8.8.8
      ```
      ```cisco
      service dhcp mgmt0
      ```

# Compute
Components:

- [Node1](#node1)

## Node1
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
