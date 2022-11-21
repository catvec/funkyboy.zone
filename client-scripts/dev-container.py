#!/usr/bin/env python
import os.path
import argparse
import subprocess
import logging
import sys

logging.basicConfig(
    level=logging.DEBUG,
)

# Constants
PROG_DIR = os.path.dirname(os.path.realpath(__file__))
DEV_CONTAINER_DIR = os.path.join(PROG_DIR, "../dev-container")

def main():
    """ Entrypoint.
    """
    # Arguments
    parser = argparse.ArgumentParser(
        description="Runs a development container",
    )

    args = parser.parse_args()

    # Run dev container
    logging.info("Running dev container")
    subprocess.run(
        ["docker", "compose", "run", "--rm", "dev_container"],
        cwd=DEV_CONTAINER_DIR,
        stdin=sys.stdin,
        stdout=sys.stdout,
    )

if __name__ == '__main__':
    main()