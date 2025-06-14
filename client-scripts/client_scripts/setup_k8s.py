#!/usr/bin/env -S pipenv run python
from typing import Optional, List
import argparse
from enum import Enum
import os
import yaml

import pydantic
from dotenv import load_dotenv

from lib.logging import logging
from setup_k8s.kubectl import KubectlClient
from setup_k8s.kustomize import KustomizeClient
from setup_k8s.strategies import BigDiffComponentStrategy, DiffComponentStrategy, ComponentAction

# Kubernetes manifests directory
PROG_DIR = os.path.dirname(os.path.realpath(__file__))
KUBERNETES_DIR = os.path.join(PROG_DIR, "../../kubernetes")
KUBECONFIG_PATH = os.path.join(KUBERNETES_DIR, "kubeconfig.yaml")

DEFAULT_COMPONENTS_SPEC = os.path.join(KUBERNETES_DIR, "components.yaml")

class DiffConfirmFail(Exception):
    """ Indicates the Kubernetes manifest difference was not accepted by the user.
    """
    def __init__(self):
        super().__init__("Failed to confirm Kubernetes manifest changes")
    
class ComponentsSpecStrategy(str, Enum):
    """ Indicates how changes in the kustomization should be treated.
    - DIFF: Uses the kubectl apply method to find differences in the resources and patch the resources
    - BIG_DIFF: Diff technique for manifests larger than kubectl apply's maximum size, computes diffs client side and sends patches to server
    """
    DIFF = "diff"
    BIG_DIFF = "big-diff"
    
class ComponentsSpecItem(pydantic.BaseModel):
    """ Specifies which kustomization to load and how to treat it.
    """
    path: str
    strategy: ComponentsSpecStrategy = ComponentsSpecStrategy.DIFF
    
class ComponentsSpec(pydantic.BaseModel):
    """ Specifies which kustomizations to load and perform actions on.
    """
    components: List[ComponentsSpecItem]

    @classmethod
    def from_yaml_file(cls, file_path: str) -> "ComponentsSpec":
        with open(file_path, 'r') as f:
            return cls(**yaml.safe_load(f))

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
        choices=list(ComponentAction),
        default=ComponentAction.CREATE,
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
        "--components-spec",
        help="JSON file following ComponentsSpec class structure which specifies which Kustomizations to load",
        default=DEFAULT_COMPONENTS_SPEC,
        dest='components_spec_path',
    )
    parser.add_argument(
        "--only-component-path", "-o",
        help="Only components with the specified path(s) will be processed",
        action='append',
        default=None,
        dest='only_component_paths',
    )
    parser.add_argument(
        "--verbose",
        help="In non-verbose mode only changed resources will be shown from command output",
        action='store_true',
        default=False,
    )

    args = parser.parse_args()

    load_dotenv()

    render_and_apply_or_delete(
        action=args.action,
        components_spec_path=args.components_spec_path,
        only_component_paths=args.only_component_paths,
        no_validate=args.no_validate,
        no_diff=args.no_diff,
        show_manifests=args.show_manifests,
        verbose=args.verbose,
    )

def render_and_apply_or_delete(
    action: ComponentAction,
    components_spec_path: str,
    only_component_paths: Optional[List[str]],
    no_validate: bool,
    no_diff: bool,
    show_manifests: bool,
    verbose: bool,
):
    kubectl = KubectlClient(kubeconfig_path=KUBECONFIG_PATH)
    kustomize = KustomizeClient()

    # Load components spec
    logging.debug("Loading components spec {}", components_spec_path)

    components_spec = ComponentsSpec.from_yaml_file(components_spec_path)

    logging.info("Successfully loaded {} item(s) from the components spec", len(components_spec.components))

    components_spec_dir = os.path.dirname(os.path.realpath(components_spec_path))

    # Normalize paths
    normalized_only_component_paths = None
    if only_component_paths is not None:
        normalized_only_component_paths = [
            os.path.abspath(path) for path in only_component_paths
        ]

    normalized_components_spec = ComponentsSpec(
        components=[
            ComponentsSpecItem(**{
                **component.model_dump(),
                "path": os.path.normpath(os.path.join(components_spec_dir, component.path)),
            })
            for component in components_spec.components
        ],
    )

    # For each item in the manifest
    for component in normalized_components_spec.components:
        # Filter components to process
        if normalized_only_component_paths is not None and component.path not in normalized_only_component_paths:
            logging.debug("Ignoring component {}", component.path)
            continue
        
        # Render Kubernetes manifests
        logging.info("Building component: {}", component.path)

        kustomize_file_path = os.path.join(components_spec_dir, component.path)
        logging.debug("Building manifests with Kustomize {}", kustomize_file_path)
        
        kustomize_build_str = kustomize.build(kustomize_file_path)
        if kustomize_build_str is None:
            logging.info("No manifest output from build, skipping component")
            continue

        logging.info("Successfully built manifests")

        # Create strategy
        strategy = None
        if component.strategy == ComponentsSpecStrategy.DIFF:
            strategy = DiffComponentStrategy(kubectl=kubectl, input_manifests=kustomize_build_str)
        elif component.strategy == ComponentsSpecStrategy.BIG_DIFF:
            strategy = BigDiffComponentStrategy(kubectl=kubectl, input_manifests=kustomize_build_str)
        else:
            logging.fatal("No strategy found for component: {}", component.strategy)
            return

        # Validate manifests
        if not no_validate:
            logging.debug("Validating manifests")

            strategy.validate(action)
        else:
            logging.info("Not validating manifests")

        # Show manifests
        if show_manifests:
            logging.debug("Kubernetes manifests")
            logging.debug(str(kustomize_build_str).replace("\\n", "\n"))

        # Show manifest diff
        if not no_diff:
            strategy.diff(action)

            logging.info("Confirm changes [y/N]")
            confirm_in = input().strip().lower()

            if confirm_in != "y":
                raise DiffConfirmFail()
        else:
            logging.info("Not computing Kubernetes manifest differences")

        # Apply Kubernetes manifest
        logging.info("{} manifests", "Applying" if action == ComponentAction.CREATE else "Deleting")
    
        strategy.do_action(action)

        logging.info("Applied manifests")


if __name__ == '__main__':
    main()
