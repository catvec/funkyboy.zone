# Salt Testing Framework

Test Salt states using Docker containers.

## Usage

```bash
cd lab/rpi-vpn/test
docker compose up --build
```

This will:
1. Start test containers
2. Apply Salt states to configure them
3. Run validation tests
4. Show results

## Containers

- **orchestrator** - Runs Salt SSH and tests
- **router** - Target for Salt configuration (10.10.10.208)
- **client** - Test client (10.10.10.209) 
- **external** - External server for NAT testing (10.10.9.200)

## Tests

Unit tests are in `tests/unit_tests/*.sh`. They use Jinja templating with pillar data.

Tests are automatically discovered and run. Results go to `results/`.