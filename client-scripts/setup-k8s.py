#!/usr/bin/env python3
import argparse
import subprocess
import logging
import os
from typing import Optional, Literal, Union

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
    def __init__(self, returncode: int, stdout: Optional[str], stderr: Optional[str]):
        super().__init__(f"Failed to build manifests with Kustomize (exit code: {returncode}), stdout={stdout}, stderr={stderr}")

class KubeDryRunError(Exception):
    """ Indicates that running Kubectl in dry run mode failed.
    """

    def __init__(self, returncode: int, stdout: Optional[str], stderr: Optional[str]):
        super().__init__(f"Failed to validate manifests using dry run mode (exit code: {returncode}), stdout={stdout}, stderr={stderr}")

class KubeDiffError(Exception):
    """ Failed to compute difference of Kubectl manifests.
    """
    def __init__(self, returncode: int, stdout: Optional[str], stderr: Optional[str]):
        super().__init__(f"Failed to compute diff of Kubernetes manifests (exit code: {returncode}), stdout={stdout}, stderr{stderr}")

class KubeDiffConfirmFail(Exception):
    """ Indicates the Kubernetes manifest difference was not accepted.
    """
    def __init__(self):
        super().__init__("Failed to confirm Kubernetes manifest changes")

class KubeApplyOrDeleteError(Exception):
    """ Indicates kubectl apply failed.
    """
    def __init__(self, action: Union[Literal["apply"], Literal["delete"]], returncode: int, stdout: Optional[str], stderr: Optional[str]):
        super().__init__(f"Failed to {action} Kubernetes manifests (exit code: {returncode}), stdout={stdout}, stderr={stderr}")

def decode_bytes(value: bytes) -> Optional[str]:
    """ Converts bytes into a string. If no value is stored in bytes then None is returned.
    """
    if value is None or len(value) == 0:
        return None

    return value.decode("utf-8")

def main():
    """ Entrypoint.
    """
    # Options
    parser = argparse.ArgumentParser(
        description="""\
            Valid, diff, and apply manifests to the Kubernetes cluster.

            When not in verbose mode only changed resources will be shown in the diff.\
        """,

    )
    parser.add_argument(
        "action",
        help="The action to run on the cluster",
        choices=["apply", "delete"],
        default="apply",
        nargs="?",
    )
    parser.add_argument(
        "--no-validate",
        help="Do not validate manifests",
        action='store_true',
        default=False,
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
    parser.add_argument(
        "--target-dir",
        help="Which Kustomization directory to build",
        default=KUBERNETES_DIR,
    )
    parser.add_argument(
        "--verbose",
        help="If provided then does not trim any command output. If not provided then the diff command will only show changed resources",
        action='store_true',
        default=False,
    )

    args = parser.parse_args()

    # Render Kubernetes manifests
    kustomize_res = subprocess.Popen(
        ["kustomize", "build", args.target_dir],
        cwd=KUBERNETES_DIR,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    kustomize_out = kustomize_res.communicate()

    if kustomize_res.wait() != 0:
        raise KustomizeBuildError(
            returncode=kustomize_res.returncode,
            stdout=decode_bytes(kustomize_out[0]),
            stderr=decode_bytes(kustomize_out[1]),
        )
    kustomize_build_str = kustomize_out[0]

    # Validate manifests
    if not args.no_validate:
        kubectl_dry_run_res = subprocess.Popen(
            ["kubectl", args.action, "-f", "-", "--dry-run=server"],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            env=dict(os.environ, KUBECONFIG=KUBECONFIG_PATH),
        )
        kubectl_dry_run_out = kubectl_dry_run_res.communicate(input=kustomize_build_str)
        
        if kubectl_dry_run_res.wait() != 0:
            raise KubeDryRunError(
                returncode=kubectl_dry_run_res.returncode,
                stdout=decode_bytes(kubectl_dry_run_out[0]),
                stderr=decode_bytes(kubectl_dry_run_out[1]),
            )

        logging.info("Validated manifests")
    else:
        logging.info("Not validating manifests")

    # Show manifest diff    
    if not args.no_diff and args.action == "apply":
        logging.info("Preparing diff")
        kubectl_diff_res = subprocess.Popen(
            ["kubectl", "diff", "-f", "-"],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            env=dict(os.environ, KUBECONFIG=KUBECONFIG_PATH),
        )
        kubectl_diff_out = kubectl_diff_res.communicate(input=kustomize_build_str)
        
        if kubectl_diff_res.wait() > 1:
            raise KubeDiffError(
                returncode=kubectl_diff_res.returncode,
                stdout=decode_bytes(kubectl_diff_out[0]),
                stderr=decode_bytes(kubectl_diff_out[1]),
            ) 

        logging.info("Proposed manifest changes")
        logging.info(decode_bytes(kubectl_diff_out[0]))
        
        logging.info("Confirm changes [y/N]")
        confirm_in = input().strip().lower()

        if confirm_in != "y":
            raise KubeDiffConfirmFail()
    elif args.action == "delete":
        logging.info("Cannot compute diff for delete")
    else:
        logging.info("Not computing Kubernetes manifest differences")

    # Show manifests
    if args.show_manifests:
        logging.debug("Kubernetes manifests")
        logging.debug(str(kustomize_build_str).replace("\\n", "\n"))

    # Apply Kubernetes manifest
    kubectl_action_res = subprocess.Popen(
        ["kubectl", args.action, "-f", "-"],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        env=dict(os.environ, KUBECONFIG=KUBECONFIG_PATH),
    )
    kubectl_action_out = kubectl_action_res.communicate(input=kustomize_build_str)
    
    if kubectl_action_res.wait() != 0:
        raise KubeApplyOrDeleteError(
            action=args.action,
            returncode=kubectl_action_res.returncode,
            stdout=decode_bytes(kubectl_action_out[0]),
            stderr=decode_bytes(kubectl_action_out[1]),
        )

    logging.info("%s Kuberenetes manifests", "Applied" if args.action == "apply" else "Deleted")
    logging.info(decode_bytes(kubectl_action_out[0]))

if __name__ == '__main__':
    main()