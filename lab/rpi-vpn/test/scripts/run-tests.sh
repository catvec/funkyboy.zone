#!/bin/bash

set -eu

PROG_DIR=$(dirname $(realpath "$0"))
TEST_DIR="$PROG_DIR/../tests/"
RESULTS_DIR="$PROG_DIR/../results"
SALT_SSH_SCRIPT="/repo/lab/rpi-vpn/scripts/salt-ssh"
ROSTER_FILE="/repo/lab/rpi-vpn/test/roster-vagrant.yaml"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Starting Salt SSH Test Framework${NC}"
echo "======================================"

# Change to repo root so salt-ssh script works properly
cd /repo/lab/rpi-vpn

# Test connectivity first
echo -e "${BLUE}Testing connectivity to containers...${NC}"
if "$SALT_SSH_SCRIPT" --roster-file="$ROSTER_FILE" 'rpi_vpn' test.ping; then
    echo -e "${GREEN}✓ All containers reachable${NC}"
else
    echo -e "${RED}✗ Container connectivity failed${NC}"
    exit 1
fi

# Apply Salt states to configure containers
echo -e "${BLUE}Applying Salt states to containers...${NC}"
if "$SALT_SSH_SCRIPT" --roster-file="$ROSTER_FILE" 'rpi_vpn' state.apply; then
    echo -e "${GREEN}✓ RPI VPN configured successfully${NC}"
else
    echo -e "${RED}✗ RPI VPN configuration failed${NC}"
    exit 1
fi

# Run all unit test scripts
echo -e "${BLUE}Running unit tests...${NC}"

# Initialize test results
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Create temporary directory for rendered tests
TEMP_TEST_DIR=$(mktemp -d)
trap "rm -rf $TEMP_TEST_DIR" EXIT

# Find and render all test scripts in the unit_tests directory
for test_script in "$TEST_DIR"/unit_tests/*.sh; do
    if [[ -f "$test_script" ]]; then
        test_name=$(basename "$test_script" .sh)
        echo -e "${YELLOW}Rendering and running test: $test_name${NC}"
        
        TOTAL_TESTS=$((TOTAL_TESTS + 1))
        
        # Render the test script using Salt's Jinja templating
        rendered_script="$TEMP_TEST_DIR/${test_name}.sh"
        if "$SALT_SSH_SCRIPT" --roster-file="$ROSTER_FILE" 'rpi_vpn' slsutil.renderer "$(cat "$test_script")" > "$rendered_script"; then
            chmod +x "$rendered_script"
            
            # Execute the rendered test script
            if "$rendered_script"; then
                echo -e "${GREEN}✓ $test_name passed${NC}"
                PASSED_TESTS=$((PASSED_TESTS + 1))
            else
                echo -e "${RED}✗ $test_name failed${NC}"
                FAILED_TESTS=$((FAILED_TESTS + 1))
            fi
        else
            echo -e "${RED}✗ $test_name failed to render${NC}"
            FAILED_TESTS=$((FAILED_TESTS + 1))
        fi
        echo
    fi
done

# Summary
echo "======================================"
echo -e "${BLUE}Test Summary:${NC}"
echo -e "Total tests: $TOTAL_TESTS"
echo -e "${GREEN}Passed: $PASSED_TESTS${NC}"
echo -e "${RED}Failed: $FAILED_TESTS${NC}"

# Save results
mkdir -p "$RESULTS_DIR"
echo "Test Results $(date)" > "$RESULTS_DIR/test_summary.txt"
echo "Total: $TOTAL_TESTS, Passed: $PASSED_TESTS, Failed: $FAILED_TESTS" >> "$RESULTS_DIR/test_summary.txt"

# Exit with appropriate code
if [[ $FAILED_TESTS -eq 0 ]]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed!${NC}"
    exit 1
fi
