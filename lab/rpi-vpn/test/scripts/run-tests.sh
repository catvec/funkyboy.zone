#!/bin/bash

set -eu

PROG_DIR=$(dirname $(realpath "$0"))
TEST_DIR="$PROG_DIR/../tests/"
RESULTS_DIR="$PROG_DIR/../results"
SALT_SSH_SCRIPT="/repo/lab/rpi-vpn/scripts/salt-ssh"
ROSTER_FILE="/repo/secret/lab/rpi-vpn/test/roster-bootstrap.yaml"
POST_SETUP_ROSTER_FILE="/repo/secret/lab/rpi-vpn/test/roster.yaml"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Starting Salt SSH Test Framework${NC}"
echo "======================================"

# Generate roster files with current IP configuration
echo "Generating roster files..."
/repo/secret/lab/rpi-vpn/test/generate-roster.sh

# Set up cleanup trap
TEMP_TEST_DIR=""
cleanup() {
    echo "Cleaning up temporary files..."
    rm -f /tmp/use-bootstrap-roster /tmp/use-post-setup-roster
    rm -f "$ROSTER_FILE"
    rm -f "$POST_SETUP_ROSTER_FILE"
    if [[ -n "$TEMP_TEST_DIR" && -d "$TEMP_TEST_DIR" ]]; then
        rm -rf "$TEMP_TEST_DIR"
    fi
}
trap cleanup EXIT

# Change to repo root so salt-ssh script works properly
cd /repo/lab/rpi-vpn

# Determine current VM state and apply configuration if needed
echo -e "${BLUE}Checking VM state...${NC}"

# Try post-setup roster first (VM already configured)
echo "Trying post-setup roster (custom port): $POST_SETUP_ROSTER_FILE"
if timeout 10 "$SALT_SSH_SCRIPT" --roster-file="$POST_SETUP_ROSTER_FILE" 'rpi_vpn' test.ping; then
    echo -e "${GREEN}✓ VM already configured (using custom port)${NC}"
    ROSTER_FILE="$POST_SETUP_ROSTER_FILE"
# Try bootstrap roster (VM in initial state)
elif echo "Trying bootstrap roster (port 22): $ROSTER_FILE" && timeout 10 "$SALT_SSH_SCRIPT" --roster-file="$ROSTER_FILE" 'rpi_vpn' test.ping; then
    echo -e "${YELLOW}VM in initial state (using port 22) - applying configuration${NC}"
    
    echo -e "${BLUE}Applying Salt states to configure VM...${NC}"
    if "$SALT_SSH_SCRIPT" --roster-file="$ROSTER_FILE" 'rpi_vpn' state.apply; then
        echo -e "${GREEN}✓ RPI VPN configured successfully${NC}"
        
        # Restart SSH service to apply new configuration
        echo -e "${BLUE}Restarting SSH service...${NC}"
        if "$SALT_SSH_SCRIPT" --roster-file="$ROSTER_FILE" 'rpi_vpn' cmd.run 'sudo systemctl restart ssh' > /dev/null 2>&1; then
            echo -e "${GREEN}✓ SSH service restarted${NC}"
            sleep 2  # Give SSH time to start on new port
        else
            echo -e "${YELLOW}⚠ Failed to restart SSH service via Salt, continuing...${NC}"
        fi
        
        # Switch to post-setup roster after configuration
        ROSTER_FILE="$POST_SETUP_ROSTER_FILE"
        
        # Verify we can connect with new port
        if ! timeout 10 "$SALT_SSH_SCRIPT" --roster-file="$ROSTER_FILE" 'rpi_vpn' test.ping > /dev/null 2>&1; then
            echo -e "${RED}✗ Failed to connect after configuration${NC}"
            exit 1
        fi
        echo -e "${GREEN}✓ Connected with custom SSH port${NC}"
    else
        echo -e "${RED}✗ RPI VPN configuration failed${NC}"
        exit 1
    fi
else
    echo -e "${RED}✗ Cannot connect to VM${NC}"
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

# Find and render all test scripts in the unit_tests directory
for test_script in "$TEST_DIR"/*.sh; do
    echo "test_script='$test_script'"
    if [[ -f "$test_script" ]]; then
        test_name=$(basename "$test_script" .sh)
        echo -e "${YELLOW}Rendering and running test: $test_name${NC}"
        
        TOTAL_TESTS=$((TOTAL_TESTS + 1))
        
        # Render the test script using Salt's Jinja templating
        rendered_script="$TEMP_TEST_DIR/${test_name}.sh"
        if "$SALT_SSH_SCRIPT" --roster-file="$ROSTER_FILE" 'rpi_vpn' slsutil.renderer "$test_script" default_renderer=jinja > "$rendered_script"; then
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
