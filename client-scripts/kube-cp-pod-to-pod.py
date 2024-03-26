#!/usr/bin/env python3
from typing import List, Tuple, TypeVar, Iterable
import re
import os
import argparse
import logging
import subprocess
import json

logging.basicConfig(level=logging.DEBUG)

class KubectlRunError(Exception):
    """ Indicates kubectl failed to run.
    """
    def __init__(self, args: List[str], error: str):
        joined_args = " ".join(args)
        super().__init__(f"Failed to run 'kubectl {joined_args}': {error}")

def kubectl(args: List[str]) -> str:
    """ Run kubectl command.
    Arguments:
        - args: Kubectl arguments

    Returns: Stdout

    Raises:
        - KubectlRunError: If command exits with non-zero code
    """
    args = [
        "kubectl",
        *args,
    ]
    logging.debug("run: %s", args)
    proc = subprocess.Popen(
        args=args,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        env=os.environ,
    )
    stdout, stderr = proc.communicate()

    if proc.returncode != 0:
        raise KubectlRunError(
            args=args,
            error=stderr.decode() if stderr is not None else "",
        )
    
    return stdout.decode() if stdout is not None else ""

class PodLabelsMatchError(Exception):
    """ Indicates we failed to match a pod based on its labels.
    """
    def __init__(self, ns: str, labels: str, reason: str):
        """ Initializes.
        Arguments:
            - ns: Namespace
            - labels: The lables which were used to match
            - reason: User friendly description of what went wrong
        """
        super().__init__(f"Failed to patch pod in '{ns}' with labels '{labels}': {reason}")

def get_pod_from_labels(ns: str, labels: str) -> str:
    """ Given match labels get one pod.
    Arguments:
        - ns: Namespace
        - labels: Kubectl -l formatted labels

    Returns: Name of pod

    Raises:
        - PodLabelsMatchError: If failed to get exactly one pod with labels
    """
    get_out = json.loads(kubectl([
        "-n",
        ns,
        "get",
        "pods",
        "-o",
        "json",
        "-l",
        labels,
    ]))

    num_matched_pods = len(get_out["items"])
    if num_matched_pods != 1:
        raise PodLabelsMatchError(
            ns=ns,
            labels=labels,
            reason=f"Expected 1 pod, got {num_matched_pods}",
        )
    
    return get_out["items"][0]["metadata"]["name"]

def get_local_containing_dir(containing_dir: str, pod: str, dir: str) -> str:
    """ Given a local containing dir and a dir with an absolute path return the path of the dir in the containing dir.
    """
    if len(pod) == 0:
        raise ValueError("pod cannot be empty")

    if len(dir) == 0:
        raise ValueError("dir cannot be empty")
    
    if dir[0] == "/":
        dir = dir[1:]
    return os.path.join(containing_dir, pod, dir.replace("/", "-"))

def cp_pod_to_pod(
    src_pod_ns: str,
    src_pod_labels: str,
    src_pod_dir: str,
    dst_pod_ns: str,
    dst_pod_labels: str,
    dst_pod_dir: str,
    download_containing_dir: str,
) -> None:
    # Get pod names
    logging.info("Getting pod names")

    src_pod_name = get_pod_from_labels(
        ns=src_pod_ns,
        labels=src_pod_labels,
    )
    dst_pod_name = get_pod_from_labels(
        ns=dst_pod_ns,
        labels=dst_pod_labels,
    )

    logging.info("Found source pod '%s/%s'", src_pod_ns, src_pod_name)
    logging.info("Found destination pod '%s/%s'", dst_pod_ns, dst_pod_name)

    # Copy files
    tmp_dir = get_local_containing_dir(
        containing_dir=download_containing_dir,
        pod=src_pod_name,
        dir=src_pod_dir,
    )

    logging.info("Downloading '%s' from '%s/%s' to '%s' locally", src_pod_dir, src_pod_ns, src_pod_name, tmp_dir)
    kubectl([
        "-n",
        src_pod_ns,
        "cp",
        f"{src_pod_name}:{src_pod_dir}",
        tmp_dir,
    ])
    logging.info("Successfully copied '%s' from '%s/%s' to '%s' locally", src_pod_dir, src_pod_ns, src_pod_name, tmp_dir)

    logging.info("Uploading '%s' from local to '%s' in '%s/%s'", tmp_dir, dst_pod_dir, dst_pod_ns, dst_pod_name)
    kubectl([
        "-n",
        dst_pod_ns,
        "cp",
        tmp_dir,
        f"{dst_pod_name}:{dst_pod_dir}",
    ])

    logging.info("Successfully copied '%s' locally to '%s' in '%s/%s'", tmp_dir, dst_pod_dir, dst_pod_ns, dst_pod_name)

    logging.info("Successfully copied '%s' from '%s/%s' (%s) to '%s' in '%s/%s' (%s)", src_pod_dir, src_pod_ns, src_pod_name, src_pod_labels, dst_pod_dir, dst_pod_ns, dst_pod_name, dst_pod_labels)


ARGPARSE_TYPE_NS_LABELS_DIR_HUMAN_FMT = "<namespace>/<labels>:<dir>, where the namespace and labels specify the pod"
_ns_labels_dir_regex = re.compile("(.*)\/(.*):(.*)")

NSLabelsDir = Tuple[str, str, str]

def argparse_type_ns_labels_dir(value: str) -> NSLabelsDir:
    """Parses a string in the format <ns>/<labels>:<dir> out to a tuple
    Arguments:
        - value: To parse

    Returns: Tuple of parsed values (<ns>, <labels>, <dir>)
    """
    matches = _ns_labels_dir_regex.findall(value)
    if len(matches) == 0:
        raise argparse.ArgumentTypeError(f"Must be in format: {ARGPARSE_TYPE_NS_LABELS_DIR_HUMAN_FMT}")
    
    return (matches[0][0], matches[0][1], matches[0][2])

def fill_in_ns_labels_dir(a: NSLabelsDir, b: NSLabelsDir) -> Tuple[NSLabelsDir, NSLabelsDir]:
    # Check
    a = list(map(lambda val: val if len(val) > 0 else None, a))
    b = list(map(lambda val: val if len(val) > 0 else None, b))
    
    if a[0] is None and b[0] is None:
        raise ValueError("Both namespaces cannot be empty")
    
    if a[1] is None and b[1] is None:
        raise ValueError("Both pod labels cannot be empty")
    
    if a[2] is None and b[2] is None:
        raise ValueError("Both pod directories cannot be empty")
    
    # Set defaults
    a_out = a
    b_out = b

    for i in range(len(a_out)):
        #  Only a or b can have a None here
        if a_out[i] is None:
            a_out[i] = b_out[i]

        if b_out[i] is None:
            b_out[i] = a_out[i]

    return (a_out, b_out,)
        

if __name__ == "__main__":
    # Parse arguments
    parser = argparse.ArgumentParser(description="Copies files from one Kubernetes pod to another")

    parser.add_argument(
        "src",
        type=argparse_type_ns_labels_dir,
        help=f"Source of file (Format: {ARGPARSE_TYPE_NS_LABELS_DIR_HUMAN_FMT})",
    )
    parser.add_argument(
        "dst",
        type=argparse_type_ns_labels_dir,
        help=f"Destination of file (Format: {ARGPARSE_TYPE_NS_LABELS_DIR_HUMAN_FMT})",
    )
    parser.add_argument(
        "--host-download-dir",
        default="k8s-download",
        help="Directory on host machine which can hold the directory which is being copied during intermediary steps."
    )

    args = parser.parse_args()

    src, dst = fill_in_ns_labels_dir(args.src, args.dst) # (args.src, args.dst,)
    download_containing_dir = os.path.abspath(args.host_download_dir)
    
    # Run logic
    cp_pod_to_pod(
        src_pod_ns=src[0],
        src_pod_labels=src[1],
        src_pod_dir=src[2],
        dst_pod_ns=dst[0],
        dst_pod_labels=dst[1],
        dst_pod_dir=dst[2],
        download_containing_dir=download_containing_dir,
    )