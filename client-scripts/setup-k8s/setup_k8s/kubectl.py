import os
import re
import subprocess
from enum import Enum
from typing import Any, Dict, List, Optional, Set, TypedDict, Union

import yaml

from .bytes_util import decode_bytes

class SendManifestsAction(str, Enum):
    """ Indicates what action should be taken on the manifest which are sent.
    """
    APPLY = "apply"
    DELETE = "delete"
    CREATE = "create"

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

class KubeSendManifestsError(Exception):
    """ Indicates kubectl apply failed.
    """
    def __init__(self, action: SendManifestsAction, returncode: int, stdout: Optional[str], stderr: Optional[str]):
        super().__init__(f"Failed to {action} Kubernetes manifests (exit code: {returncode}), stdout={stdout}, stderr={stderr}")

class KubeGetError(Exception):
    """ Indicates kubectl get failed.
    """
    def __init__(self, namespace: str, kind: str, name: str, returncode: int, stdout: Optional[str], stderr: Optional[str]):
        super().__init__(f"Failed to get {kind}/{name} from {namespace} namespace (exit code: {returncode}), stdout={stdout}, stderr={stderr}")

class KubePatchError(Exception):
    """ Indicates kubectl patch failed.
    """
    def __init__(self, namespace: str, kind: str, name: str, returncode: int, stdout: Optional[str], stderr: Optional[str]):
        super().__init__(f"Failed to patch {kind}/{name} from {namespace} namespace (exit code: {returncode}), stdout={stdout}, stderr={stderr}")

class KubeDryRunRes(TypedDict):
    """ Results of Kubectl dry run.
    Fields:
    - missing_namespaces: List of namespaces which are missing
    - output: Text sent by dry run
    """
    missing_namespaces: Optional[List[str]]
    output: Optional[str]


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
    diff: Optional[str]

class KubeApplyRes(TypedDict):
    """ Results of kubectl apply.
    Arguments:
    - output: Apply output
    """
    output: Optional[str]

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

    def __check_stderr_for_missing_namespaces(self, stderr: Optional[str]) -> KubeStderrMissingNamespaces:
        """ Decode kubectl's stderr output to check for missing namespace errors.
        Arguments:
        - stderr: Text to check

        Returns: Results of decoding
        """
        if stderr is None:
            return {
                'missing_namespaces': [],
                'only_missing_namespaces_errors': True,
            }

        namespace_error_re = re.compile(r"^Error from server \(NotFound\):.*namespaces \"(.*)\" not found$")
        missing_namespaces: Set[str] = set()
        only_namespace_errors = True

        for stderr_line in stderr.strip().split("\n"):
            err_match = namespace_error_re.match(stderr_line.strip())
            if err_match:
                missing_namespaces.add(err_match.group(1))
            else:
                only_namespace_errors = False

        return {
            'missing_namespaces': list(missing_namespaces),
            'only_missing_namespaces_errors': only_namespace_errors,
        }

    def send_manifests_dry_run(self, action: SendManifestsAction, input_manifests: str) -> KubeDryRunRes:
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
        out = res.communicate(input=input_manifests.encode("utf-8"))

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
            'missing_namespaces': None,
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
        out = res.communicate(input=input_manifests.encode("utf-8"))
        
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
            'missing_namespaces': [],
            'diff': decode_bytes(out[0]),
        }
    
    def send_manifests(self, action: SendManifestsAction, input_manifests: str) -> KubeApplyRes:
        """ Apply manifests to server.
        Arguments:
        - action: Whether the apply should create or delete resources
        - input_manifests: YAML manifests of resources

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
        out = res.communicate(input=input_manifests.encode("utf-8"))
        
        if res.wait() != 0:
            raise KubeSendManifestsError(
                action=action,
                returncode=res.returncode,
                stdout=decode_bytes(out[0]),
                stderr=decode_bytes(out[1]),
            )
        
        return {
            'output': decode_bytes(out[0]),
        }
    
    def patch(self, namespace: str, kind: str, name: str, patch: str, dry_run=False) -> KubeApplyRes:
        args = ["kubectl", "-n", namespace, "patch", kind, name, "--type", "json", "-p", "-"]

        if dry_run:
            args.extend(["--dry-run", "server"])

        res = subprocess.Popen(
            args,
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            env=dict(os.environ, KUBECONFIG=self.kubeconfig_path),
        )
        out = res.communicate(input=patch.encode("utf-8"))
        
        if res.wait() != 0:
            raise KubePatchError(
                namespace=namespace,
                kind=kind,
                name=name,
                returncode=res.returncode,
                stdout=decode_bytes(out[0]),
                stderr=decode_bytes(out[1]),
            )
        
        return {
            'output': decode_bytes(out[0]),
        }
    
    def get(self, namespace: str, kind: str, name: str) -> Optional[Dict[str, Any]]:
        """ Get a resource from a namespace.
        """
        res = subprocess.Popen(
            ["kubectl", "-n", namespace, "get", "-o", "yaml", kind, name],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            env=dict(os.environ, KUBECONFIG=self.kubeconfig_path),
        )
        out = res.communicate()
        
        if res.wait() > 1:
            stderr = decode_bytes(out[1])
            if stderr is not None:
                if "(NotFound)" in stderr:
                    return None
                elif "doesn't have a resource type" in stderr:
                    return None

            raise KubeGetError(
                namespace=namespace,
                kind=kind,
                name=name,
                returncode=res.returncode,
                stdout=decode_bytes(out[0]),
                stderr=stderr,
            )
        
        stdout = decode_bytes(out[0])
        if stdout is None:
            return None
        
        return yaml.safe_load(stdout)
            
        