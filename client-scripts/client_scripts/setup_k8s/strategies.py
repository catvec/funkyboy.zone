from typing import Any, Dict, List, Optional, TypedDict
from abc import ABC, abstractmethod
from enum import Enum
import json
import yaml

from loguru import logger as logging

from .yaml import load_all_yaml
from .kubectl import KubeApplyRes, KubeDryRunRes, KubectlClient, SendManifestsAction
from lib.print_diff import print_diff

class ComponentAction(str, Enum):
    """ An action to be taken on a component.
    - CREATE: Create the component resources
    - DELETE: Delete the component resources
    """
    CREATE = "create"
    DELETE = "delete"

class ComponentStrategy(ABC):
    """ Logic to reconcile differences in components.

    Fields:
        input_manifests: YAML manifests for different Kubernetes objects, each object is separated by newlines and 3 dashes
    """
    input_manifests: str

    def __init__(self, input_manifests: str):
        """ Initialize."""
        self.input_manifests = input_manifests

    @abstractmethod
    def validate(self, action: ComponentAction) -> None:
        """ Ensure Kubernetes manifests are valid.

        Arguments:
            - action: The action to validate manifests for
        """
        raise NotImplementedError()
    
    @abstractmethod
    def diff(self, action: ComponentAction) -> None:
        """ Print diff of what will take place to console.

        Arguments:
            - action: The action to show a diff for
        """
        raise NotImplementedError()
    
    @abstractmethod
    def do_action(self, action: ComponentAction) -> None:
        """ Perform the specified action.

        Arguments:
            - action: The action to complete
        """
        raise NotImplementedError()
    
class DiffComponentStrategy(ComponentStrategy):
    """ Uses the kubectl apply method to patch differences in resources.
    """
    _kubectl: KubectlClient

    def __init__(self, kubectl: KubectlClient, input_manifests: str) -> None:
        super().__init__(input_manifests=input_manifests)
        self._kubectl = kubectl

    def validate(self, action: ComponentAction) -> None:
        """ Runs kubectl dry-run for the action.
        """
        kubectl_action = SendManifestsAction.APPLY if action == ComponentAction.CREATE else SendManifestsAction.DELETE
        dry_run_res = self._kubectl.send_manifests_dry_run(kubectl_action, self.input_manifests)
        
        if dry_run_res["missing_namespaces"] is not None:
            for ns in dry_run_res['missing_namespaces']:
                logging.warning("Must create namespace: {}", ns)

            logging.warning("Validation might not be accurate because resource(s) were specified in namespace(s) which do not exist")
        
        logging.info("Validated manifests")
    
    def diff(self, action: ComponentAction) -> None:
        """ Uses kubectl diff.
        """
        if action == ComponentAction.CREATE:
            diff_res = self._kubectl.diff(self.input_manifests)

            if diff_res["missing_namespaces"] is not None:
                for ns in diff_res['missing_namespaces']:
                    logging.warning("Must create namespace: {}", ns)

                logging.warning("Diff might not be accurate because resource(s) were specified in namespace(s) which do not exist")

            logging.info("Proposed manifest changes")
            logging.info(print_diff(diff_res['diff']))
        elif action == ComponentAction.DELETE:
            logging.info("Cannot compute diff for delete, displaying manifests which will be passed to delete command: \n{}", self.input_manifests.replace("\\n", "\n"))
    
    def do_action(self, action: ComponentAction) -> None:
        """ Runs kubectl apply or delete.
        """
        kubectl_action = SendManifestsAction.APPLY if action == ComponentAction.CREATE else SendManifestsAction.DELETE
        apply_res = self._kubectl.send_manifests(kubectl_action, self.input_manifests)

        logging.info("{} Kuberenetes manifests", "Applied" if action == ComponentAction.CREATE else "Deleted")

        if apply_res["output"] is None:
            logging.info("not output")
        else:
            for line in apply_res['output'].split("\n"):
                if "unchanged" in line or len(line.strip()) == 0:
                    continue

                print(line)

class HashedManifest(TypedDict):
    """ Holds the hash of a manifest.
    Fields:
    - manifest: Which was hashed
    - hash: Hash value
    """
    manifest: Dict[str, Any]
    hash: str

class BigDiffPlanAction(str, Enum):
    """ Indicates what action should be taken for a plan.
    """
    CREATE = "create"
    REPLACE = "replace"

    def to_send_manifest_action(self) -> SendManifestsAction:
        if self == BigDiffPlanAction.CREATE:
            return SendManifestsAction.CREATE
        else:
            return SendManifestsAction.REPLACE

class BigDiffPlan(TypedDict):
    """ Represents what must happen to reconcile differences in a manifest.
    Fields:
    - action: To take
    - manifest: To send to server
    """
    action: BigDiffPlanAction
    manifest: str

class ManifestResource(TypedDict):
    parsed_manifest: Dict[str, Any]
    kind: str
    name: str
    namespace: Optional[str]

INPUT_MANIFEST_HASH_ANNOTATION = "funkyboy.zone/input-manifest-hash"

class BigDiffComponentStrategy(ComponentStrategy):
    """ When resources are created the hash of the input manifest is stored as an annotation. If the hash of the input manifest changes the resource is wholesale created.
    """
    _kubectl: KubectlClient
    _plans: List[BigDiffPlan]

    def __init__(self, kubectl: KubectlClient, input_manifests: str) -> None:
        super().__init__(input_manifests=input_manifests)
        self._kubectl = kubectl
        self._plans = self._generate_plans(self.input_manifests)

    def _hash_dict(self, value: Dict[str, Any]) -> str:
        """ Given a dictionary produce a hash of its contents.
        Arguments:
        - value: To hash

        Returns: Hash
        """
        return str(hash(json.dumps(value, sort_keys=True)))
    
    def _parse_manifests(self, in_manifests: str) -> List[ManifestResource]:
        """ Convert manifests into ManifestResource dicts.

        Arguments:
            - in_manifests: The manifests to parse, should be YAML Kubernetes objects separated by 3 dashes

        Returns: List of parsed manifests
        """
        parsed_manifests = load_all_yaml(in_manifests)

        resources = []

        for manifest_i in range(len(parsed_manifests)):
            parsed_manifest = parsed_manifests[manifest_i]

            # Get namespace
            ns = None
            if "namespace" in parsed_manifest["metadata"]:
                ns = parsed_manifest["metadata"]["namespace"]

            # Get kind and name
            kind = parsed_manifest["kind"]
            name = parsed_manifest["metadata"]["name"]

            resources.append(ManifestResource(
                parsed_manifest=parsed_manifest,
                kind=kind,
                name=name,
                namespace=ns,
            ))

        return resources
    
    def _generate_plans(self, in_manifests: str) -> List[BigDiffPlan]:
        """ Given a set desired states determine what must be sent to the server to make the remote manifests match.
        """
        resources = self._parse_manifests(in_manifests)

        plans = []

        for resource in resources:
            # Hash manifest
            manifest_hash = self._hash_dict(resource["parsed_manifest"])

            # Modify manifest to include hash annotation
            annotated_manifest = resource["parsed_manifest"]
            if "annotations" not in annotated_manifest["metadata"]:
                annotated_manifest["metadata"]["annotations"] = {}

            annotated_manifest["metadata"]["annotations"][INPUT_MANIFEST_HASH_ANNOTATION] = manifest_hash

            annotated_manifest_str = yaml.dump(annotated_manifest)

            # Get remote resource
            remote_res = self._kubectl.get(resource["namespace"], resource["kind"], resource["name"])
            if remote_res is None:
                logging.info("PLAN: need to create {} - {}/{}", resource["namespace"], resource["kind"], resource["name"])
                # Resource doesn't exist, create it
                plans.append(BigDiffPlan(
                    action=BigDiffPlanAction.CREATE,
                    manifest=annotated_manifest_str,
                ))
            else:
                # Resource exists check if input manifest hash differs
                remote_input_hash = None
                if "annotations" in resource["parsed_manifest"]["metadata"] and INPUT_MANIFEST_HASH_ANNOTATION in resource["parsed_manifest"]["metadata"]["annotations"]:
                    remote_input_hash = resource["parsed_manifest"]["metadata"]["annotations"][INPUT_MANIFEST_HASH_ANNOTATION]
                
                if remote_input_hash != manifest_hash:
                    # Replace resource because input manifest changed
                    plans.append(BigDiffPlan(
                        action=BigDiffPlanAction.REPLACE,
                        manifest=annotated_manifest_str,
                    ))

        return plans
    
    def _perform_plans(self, plans: List[BigDiffPlan]) -> List[KubeApplyRes]:
        """ Run the plan items on the Kubernetes cluster.
        """
        outputs = []
        for plan in plans:
            logging.info("performed plan: {}", plan["action"].to_send_manifest_action())
            outputs.append(self._kubectl.send_manifests(plan["action"].to_send_manifest_action(), plan["manifest"]))

        return outputs
    
    def _dry_run_plans(self, plans: List[BigDiffPlan]) -> List[KubeDryRunRes]:
        """ Use kubectl --dry-run for each plan action.
        """
        outputs = []
        for plan in plans:
            outputs.append(self._kubectl.send_manifests_dry_run(plan["action"].to_send_manifest_action(), plan["manifest"]))

        return outputs 

    def validate(self, action: ComponentAction) -> None:
        """ Dry run plans.
        """
        dry_run_results = self._dry_run_plans(self._plans)
        
        for res in dry_run_results:    
            if res["missing_namespaces"] is not None:
                for ns in res['missing_namespaces']:
                    logging.warning("Must create namespace: {}", ns)

                logging.warning("Validation might not be accurate because resource(s) were specified in namespace(s) which do not exist")
        
        logging.info("Validated manifests")
    
    def diff(self, action: ComponentAction) -> None:
        """ Dry run plans to get diff.
        """
        dry_run_results = self._dry_run_plans(self._plans)

        for res in dry_run_results:
            if res["missing_namespaces"] is not None:
                for ns in res['missing_namespaces']:
                    logging.warning("Must create namespace: {}", ns)

                logging.warning("Diff might not be accurate because resource(s) were specified in namespace(s) which do not exist")

            logging.info("Proposed manifest changes")
            logging.info(print_diff(res["output"]))
    
    def do_action(self, action: ComponentAction) -> None:
        """ Run plans.
        """
        if action == ComponentAction.CREATE:
            results = self._perform_plans(self._plans)

            logging.info("Applied Kuberenetes manifests")

            for res in results:
                if res["output"] is None:
                    logging.info("not output")
                else:
                    for line in res['output'].split("\n"):
                        if "unchanged" in line or len(line.strip()) == 0:
                            continue

                        print(line)
        else:
            # Delete
            res = self._kubectl.send_manifests(SendManifestsAction.DELETE, self.input_manifests)

            if res["output"] is None:
                logging.info("not output")
            else:
                for line in res['output'].split("\n"):
                    if "unchanged" in line or len(line.strip()) == 0:
                        continue

                    print(line)