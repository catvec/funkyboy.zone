# Salt Testing Framework - Vagrant

Test Salt states using full VMs with complete kernel support for nftables and networking.

## Prerequisites

- [Vagrant](https://www.vagrantup.com/downloads)
- [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
- [Bundler](https://bundler.io/) (for Ruby dependency management)

## Usage

```bash
cd lab/rpi-vpn/test

# Install Ruby dependencies
bundle install

# Start and provision VMs
vagrant up

# Run tests manually
vagrant ssh orchestrator -c "/repo/lab/rpi-vpn/test/scripts/run-tests.sh"
```

This will:
1. Start 3 VMs: rpi-vpn, external, orchestrator
2. Install Salt SSH on orchestrator
3. Then you manually run the tests which will:
   - Apply Salt states to rpi-vpn VM
   - Run validation tests with full kernel support
   - Show results

## Configuration

VM IP addresses are configured in `vm-config.env`. Default values:

- **orchestrator** (10.10.10.210 private, 10.10.9.100 public) - Runs Salt SSH and tests
- **rpi-vpn** (10.10.10.208 private, 10.10.9.10 public) - Target for Salt configuration  
- **external** (10.10.9.200) - External server for NAT testing

## Tests

Unit tests are in `tests/unit_tests/*.sh`. They use Jinja templating with pillar data.

Results go to `results/test_summary.txt`.

## Commands

```bash
# Start and provision VMs
vagrant up

# Run tests
vagrant ssh orchestrator -c "/repo/lab/rpi-vpn/test/scripts/run-tests.sh"

# Re-run tests
vagrant ssh orchestrator -c "/repo/lab/rpi-vpn/test/scripts/run-tests.sh"

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