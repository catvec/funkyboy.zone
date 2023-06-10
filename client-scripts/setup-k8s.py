#!/usr/bin/env python3
import argparse
import subprocess
import logging
import os
from typing import Optional, Literal, Union, List, TypedDict
import re
import sys
import shutil

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

class KustomizeBinNotFound(Exception):
    """ Indicates the kustomize client could not be found.
    """
    def __init__(self):
        super().__init__("Failed to find kustomize binary")

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

class KubeDryRunRes(TypedDict):
    """ Results of Kubectl dry run.
    Fields:
    - missing_namespaces: List of namespaces which are missing
    - output: Text sent by dry run
    """
    missing_namespaces: Optional[List[str]]
    output: str


class KubeStderrMissingNamespaces(TypedDict):
    """ Results of decoding the kubectl stderr to check for missing namespace errors.
    Fields:
    - missing_namespaces: The namespaces which were missing
    - only_missing_namespaces_errors: If the only errors in the output were missing namespaces errors
    """
    missing_namespaces: Optional[List[str]]
    only_missing_namespaces_errors: bool

class KubeDiffRes(TypedDict):
    """ Results of kubectl diff.
    Arguments:
    - missing_namespaces: The namespaces which were missing from the server
    - diff: Diff output
    """
    missing_namespaces: Optional[List[str]]
    diff: str

class KubeApplyRes(TypedDict):
    """ Results of kubectl apply.
    Arguments:
    - output: Apply output
    """
    output: str

class KubectlClient:
    """ Client for kubectl tool.
    Fields:
    - kubeconfig_path: Location of Kubeconfig file
    """
    kubeconfig_path: str

    def __init__(self, kubeconfig_path: str):
        """ Initialize KubectlClient.
        Arguments:
        - kubeconfig_path: See KubectlClient.kubeconfig_path
        """
        self.kubeconfig_path = kubeconfig_path

    def __check_stderr_for_missing_namespaces(self, stderr: str) -> KubeStderrMissingNamespaces:
        """ Decode kubectl's stderr output to check for missing namespace errors.
        Arguments:
        - stderr: Text to check

        Returns: Results of decoding
        """
        namespace_error_re = re.compile("^Error from server \(NotFound\): namespaces \"(.*)\" not found$")
        missing_namespaces = set()
        only_namespace_errors = True

        for stderr_line in stderr.strip().split("\n"):
            err_match = namespace_error_re.match(stderr_line.strip())
            if err_match:
                missing_namespaces.add(err_match.group(1))
            else:
                only_namespace_errors = False

        return {
            'missing_namespaces': missing_namespaces,
            'only_missing_namespaces_errors': only_namespace_errors,
        }

    def dry_run(self, action: Union[Literal["apply"], Literal["delete"]], input_manifests: str) -> KubeDryRunRes:
        """ Dry run applying manifests against the server.
        Arguments:
        - action: Whether the dry run should simulate an apply or delete
        - input_manifests: Input YAML to dry run apply

        Returns: Results of dry run

        Raises:
        - KubeDryRunError: If dry run failed
        """
        res = subprocess.Popen(
            ["kubectl", action, "-f", "-", "--dry-run=server"],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            env=dict(os.environ, KUBECONFIG=self.kubeconfig_path),
        )
        out = res.communicate(input=input_manifests)

        if res.wait() != 0:
            # Ignore if the only errors are about namespaces not existing
            stderr = decode_bytes(out[1])
            
            ns_errs = self.__check_stderr_for_missing_namespaces(stderr)

            if not ns_errs['only_missing_namespaces_errors']:
                raise KubeDryRunError(
                    returncode=res.returncode,
                    stdout=decode_bytes(out[0]),
                    stderr=stderr,
                )

            return {
                'missing_namespaces': ns_errs['missing_namespaces'],
                'output': decode_bytes(out[0]),
            }
        
        return {
            'output': decode_bytes(out[0]),
        }

    def diff(self, input_manifests: str) -> KubeDiffRes:
        """ Determine difference between resources on server and provided manifests.
        Arguments:
        - input_manifests: YAML of resources of which to diff

        Returns: Diff results

        Raises:
        - KubeDiffError: If error occurs when diffing
        """
        res = subprocess.Popen(
            ["kubectl", "diff", "-f", "-"],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            env=dict(os.environ, KUBECONFIG=self.kubeconfig_path),
        )
        out = res.communicate(input=input_manifests)
        
        if res.wait() > 1:
            # Ignore missing namespace errors
            stderr = decode_bytes(out[1])

            ns_errs = self.__check_stderr_for_missing_namespaces(stderr)

            if not ns_errs['only_missing_namespaces_errors']:
                raise KubeDiffError(
                    returncode=res.returncode,
                    stdout=decode_bytes(out[0]),
                    stderr=stderr,
                )
            
        return {
            'diff': decode_bytes(out[0]),
        }
    
    def apply(self, action: Union[Literal["apply"], Literal["delete"]], input_manifests: str) -> KubeApplyRes:
        """ Apply manifests to server.
        Arguments:
        - action: Whether the apply should create or delete resources
        - input_manifests: YAML mainfests of resources

        Returns: Result of apply

        Raises:
        - KubeApplyOrDeleteError: If an error occurred while applying
        """
        res = subprocess.Popen(
            ["kubectl", action, "-f", "-"],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            env=dict(os.environ, KUBECONFIG=self.kubeconfig_path),
        )
        out = res.communicate(input=input_manifests)
        
        if res.wait() != 0:
            raise KubeApplyOrDeleteError(
                action=action,
                returncode=res.returncode,
                stdout=decode_bytes(out[0]),
                stderr=decode_bytes(out[1]),
            )
        
        return {
            'output': decode_bytes(out[0]),
        }


class KustomizeClient:
    """ Client which invokes Kustomize.
    Arguments:
    - __kustomize_cmd_name: Internal field used to memoize the found kustomize cmd name
    """
    __kustomize_cmd_name: Optional[List[str]]

    def __init__(self):
        self.__kustomize_cmd_name = None

    def __build_cmd(self, args: List[str]) -> List[str]:
        """ Constructs a command line string given the arguments.
        Arguments:
        - args: Kustomize arguments

        Returns: Kustomize command line construction

        Raises:
        - KustomizeBinNotFound: If no Kustomize binary could not be found
        """
        if self.__kustomize_cmd_name is None:
            if shutil.which("kustomize") is not None:
                self.__kustomize_cmd_name = ["kustomize"]
            elif shutil.which("kubectl") is not None:
                self.__kustomize_cmd_name = ["kubectl", "kustomize"]
            else:
                raise KustomizeBinNotFound()

        return self.__kustomize_cmd_name + args
        

    def build(self, dir: str) -> str:
        """ Use Kustomize to build a Kustomize project.
        Arguments:
        - dir: Directory of Kustomize project

        Returns: Kustomize YAML output

        Raises:
        - KustomizeBuildError: If build encounters an error
        """        
        res = subprocess.Popen(
            self.__build_cmd([dir]),
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
        out = res.communicate()

        if res.wait() != 0:
            raise KustomizeBuildError(
                returncode=res.returncode,
                stdout=decode_bytes(out[0]),
                stderr=decode_bytes(out[1]),
            )
        
        return out[0]

def main():
    """ Entrypoint.
    """
    # Options
    parser = argparse.ArgumentParser(
        description="""\
            Valid, diff, and apply manifests to the Kubernetes cluster.

            When not in verbose mode only changed resources will be shown in output.\
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
        help="In non-verbose mode only changed resources will be shown from command output",
        action='store_true',
        default=False,
    )

    args = parser.parse_args()

    render_and_apply_or_delete(
        action=args.action,
        target_dir=args.target_dir,
        no_validate=args.no_validate,
        no_diff=args.no_diff,
        show_manifests=args.show_manifests,
        verbose=args.verbose,
    )

def render_and_apply_or_delete(
    action: Union[Literal["apply"], Literal["delete"]],
    target_dir: str,
    no_validate: bool,
    no_diff: bool,
    show_manifests: bool,
    verbose: bool,
):
    kubectl = KubectlClient(kubeconfig_path=KUBECONFIG_PATH)
    kustomize = KustomizeClient()
    
    # Render Kubernetes manifests
    logging.info("Building manifests with Kustomize")
    
    kustomize_build_str = kustomize.build(target_dir)

    logging.info("Successfully built manifests")

    # Validate manifests
    if not no_validate:
        logging.info("Validating manifests")

        dry_run_res = kubectl.dry_run(kustomize_build_str)
        
        if 'missing_namespaces' in dry_run_res:
            for ns in dry_run_res['missing_namespaces']:
                logging.warning("Must create namespace: %s", ns)

            logging.warning("Validation might not be accurate because resource(s) were specified in namespace(s) which do not exist")
        
        logging.info("Validated manifests")
    else:
        logging.info("Not validating manifests")

    # Show manifest diff    
    if not no_diff and action == "apply":
        logging.info("Preparing diff")

        diff_res = kubectl.diff(kustomize_build_str)

        if 'missing_namespaces' in diff_res:
            for ns in diff_res['missing_namespaces']:
                logging.warning("Must create namespace: %s", ns)

            logging.warning("Diff might not be accurate because resource(s) were specified in namespace(s) which do not exist")

        logging.info("Proposed manifest changes")
        logging.info(diff_res['diff'])
        
        logging.info("Confirm changes [y/N]")
        confirm_in = input().strip().lower()

        if confirm_in != "y":
            raise KubeDiffConfirmFail()
    elif action == "delete":
        logging.info("Cannot compute diff for delete, displaying manifests which will be passed to delete command: \n%s", decode_bytes(kustomize_build_str).replace("\\n", "\n"))
        logging.info("Confirm delete of manifests? [y/N]")

        confirm_in = input().strip().lower()
        if confirm_in != "y":
            raise KubeDiffConfirmFail()
    else:
        logging.info("Not computing Kubernetes manifest differences")

    # Show manifests
    if show_manifests:
        logging.debug("Kubernetes manifests")
        logging.debug(str(kustomize_build_str).replace("\\n", "\n"))

    # Apply Kubernetes manifest
    logging.info("%s manifests", "Applying" if action == "apply" else "Deleting")
    
    apply_res = kubectl.apply(action, kustomize_build_str)

    logging.info("%s Kuberenetes manifests", "Applied" if action == "apply" else "Deleted")
    for line in apply_res['output'].split("\n"):
        if "unchanged" in line and not verbose or len(line.strip()) == 0:
            continue

        print(line)

    logging.info("Applied manifests")

if __name__ == '__main__':
    main()
