#!/usr/bin/env python3
import os.path
import argparse
import subprocess
import sys
import logging

# Kubernetes manifests directory
KUBERNETES_DIR = os.path.dirname(os.path.realpath(__file__))
KUBECONFIG_PATH = os.path.join(KUBERNETES_DIR, "kubeconfig.yaml")

# Errors
class KustomizeBuildError(Exception):
    """ Indicates kustomize failed to build manifests.
    """
    def __init__(self):
        super("Failed to build manifests with Kustomize")

class KubeDiffError(Exception):
    """ Failed to compute difference of Kubectl manifests.
    """
    def __init__(self):
        super("Failed to compute diff of Kubernetes manifests")

def main():
    """ Entrypoint.
    """
    # Options
    parser = argparse.ArgumentParser(
        description="Apply manifests to the Kubernetes cluster"
    )
    parser.add_argument(
        "--no-plan",
        help="Do not plan potential operators (Useful if planning would cause an error, like in the case of non-existent custom resource destinations)",
        action='store_true',
    )

    args = parser.parse_args()

    # Render Kubernetes manifests
    kustomize_res = subprocess.run(
        ["kustomize", "build", "."],
        cwd=KUBERNETES_DIR,
        stdout=subprocess.PIPE,
    )
    if kustomize_res.returncode != 0:
        raise KustomizeBuildError()

    # Show manifest diff    
    if not args.no_plan:
        kubectl_diff_res = subprocess.run(
            ["kubectl", "diff", "-f", "-"],
            stdin=kustomize_res.stdout,
            stdout=subprocess.PIPE,
            env={
                "KUBECONFIG": KUBECONFIG_PATH,
            }
        )
        if kubectl_diff_res.returncode != 0:
            raise KubeDiffError()

if __name__ == '__main__':
    main()