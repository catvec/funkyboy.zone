#!/usr/bin/env python3
import os.path
import argparse
import subprocess
import sys
import logging
import os
import io

logging.basicConfig(
    level=logging.DEBUG,
)

# Kubernetes manifests directory
PROG_DIR = os.path.dirname(os.path.realpath(__file__))
KUBERNETES_DIR = os.path.join(PROG_DIR, "../kubernetes")
KUBECONFIG_PATH = os.path.join(KUBERNETES_DIR, "kubeconfig.yaml")

# Errors
class KustomizeBuildError(Exception):
    """ Indicates kustomize failed to build manifests.
    """
    def __init__(self):
        super().__init__("Failed to build manifests with Kustomize")

class KubeApplyDryRunError(Exception):
    """ Indicates that running Kubectl apply in dry run mode failed.
    """

    def __init__(self):
        super().__init__("Failed to validate manifests using dry run mode")

class KubeDiffError(Exception):
    """ Failed to compute difference of Kubectl manifests.
    """
    def __init__(self):
        super().__init__("Failed to compute diff of Kubernetes manifests")

class KubeDiffConfirmFail(Exception):
    """ Indicates the Kubernetes manifest difference was not accepted.
    """
    def __init__(self):
        super().__init__("Failed to confirm Kubernetes manifest changes")

class KubeApplyError(Exception):
    """ Indicates kubectl apply failed.
    """
    def __init__(self):
        super().__init__("Failed to apply Kubernetes manifests")

def main():
    """ Entrypoint.
    """
    # Options
    parser = argparse.ArgumentParser(
        description="Apply manifests to the Kubernetes cluster"
    )
    parser.add_argument(
        "--no-diff",
        help="Do not compute the diff against the current Kubernetes cluster (Useful if this would cause an error, like in the case of non-existent custom resource definitions)",
        action='store_true',
        default=False,
    )
    parser.add_argument(
        "--show-manifests",
        help="Prints manifest YAML during apply process",
        action='store_true',
        default=False,
    )

    args = parser.parse_args()

    # Render Kubernetes manifests
    kustomize_res = subprocess.run(
        ["kustomize", "build", "."],
        cwd=KUBERNETES_DIR,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    if kustomize_res.returncode != 0:
        logging.error("kustomize error: %s", kustomize_res.stderr)
        raise KustomizeBuildError()
    kustomize_build_str = kustomize_res.stdout

    # Validate manifests
    kubectl_dry_run_res = subprocess.Popen(
        ["kubectl", "apply", "-f", "-", "--dry-run=server"],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        env=dict(os.environ, KUBECONFIG=KUBECONFIG_PATH),
    )
    kubectl_dry_run_out = kubectl_dry_run_res.communicate(input=kustomize_build_str)
    
    if kubectl_dry_run_res.returncode != 0:
        logging.error("kubectl apply dry run error: %s", kubectl_dry_run_out[1].decode('utf-8') if kubectl_dry_run_out[1] is not None else "<No error returned>")
        raise KubeApplyDryRunError()

    logging.info("Validated manifests")
    logging.info(kubectl_dry_run_out[0].decode('utf-8'))

    # Show manifest diff    
    if not args.no_diff:
        kubectl_diff_res = subprocess.Popen(
            ["kubectl", "diff", "-f", "-"],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            env=dict(os.environ, KUBECONFIG=KUBECONFIG_PATH),
        )
        kubectl_diff_out = kubectl_diff_res.communicate(input=kustomize_build_str)

        if kubectl_diff_res.returncode != 0:
            logging.error("kubectl diff error: %s", kubectl_diff_out[1].decode('utf-8') if kubectl_diff_out[1] is not None else "<No error returned>")
            raise KubeDiffError()

        logging.info("Proposed manifest changes")
        kubectl_diff_str = kubectl_diff_out[0].decode('utf-8')
        logging.info(kubectl_diff_str if len(kubectl_diff_str) > 0 else "<Empty string>")

        logging.info("Confirm changes [y/N]")
        confirm_in = input().strip().lower()

        if confirm_in != "y":
            raise KubeDiffConfirmFail()
    else:
        logging.info("Not computing Kubernetes manifest differences")

    # Show manifests
    if args.show_manifests:
        logging.debug("Kubernetes manifests")
        logging.debug(str(kustomize_build_str).replace("\\n", "\n"))

    # Apply Kubernetes manifest
    kubectl_apply_res = subprocess.Popen(
        ["kubectl", "apply", "-f", "-"],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        env=dict(os.environ, KUBECONFIG=KUBECONFIG_PATH),
    )
    kubectl_apply_out = kubectl_apply_res.communicate(input=kustomize_build_str)
    
    if kubectl_apply_res.returncode != 0:
        logging.error("kubectl apply error: %s", kubectl_apply_out[1].decode('utf-8') if kubectl_apply_out[1] is not None else "<No error returned>")
        raise KubeApplyError()

    logging.info("Applied Kuberenetes manifests")
    logging.info(kubectl_apply_out[0].decode('utf-8'))

if __name__ == '__main__':
    main()