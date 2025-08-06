# Salt Testing Framework - Vagrant

Test Salt states using full VMs with complete kernel support for nftables and networking.

## Prerequisites

- [Vagrant](https://www.vagrantup.com/downloads)
- [VirtualBox](https://www.virtualbox.org/wiki/Downloads)

## Usage

```bash
cd lab/rpi-vpn/test
vagrant up
```

This will:
1. Start 3 VMs: rpi-vpn, external, orchestrator
2. Install Salt SSH on orchestrator
3. Apply Salt states to rpi-vpn VM
4. Run validation tests with full kernel support
5. Show results

## VMs

- **orchestrator** (10.10.10.210) - Runs Salt SSH and tests
- **rpi-vpn** (10.10.10.208) - Target for Salt configuration  
- **external** (10.10.9.200) - External server for NAT testing

## Tests

Unit tests are in `tests/unit_tests/*.sh`. They use Jinja templating with pillar data.

Results go to `results/test_summary.txt`.

## Commands

```bash
# Start VMs and run tests
vagrant up

# Re-run tests only
vagrant provision orchestrator

# SSH into a VM
vagrant ssh rpi-vpn

# Stop VMs
vagrant halt

# Clean up
vagrant destroy
```

## Advantages over Docker

- ✅ Full kernel support for nftables/iptables
- ✅ Real networking interfaces and routing  
- ✅ Complete systemd/init system
- ✅ Realistic firewall rule testing