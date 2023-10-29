from abc import ABC, abstractmethod
from enum import Enum
import logging
import json
from typing import Any, Dict, List, TypedDict, Union
from setup_k8s.yaml import load_all_yaml

import yaml

from .kubectl import KubeApplyRes, KubeDiffRes, KubeDryRunRes, KubectlClient, SendManifestsAction

class ComponentAction(str, Enum):
    """ An action to be taken on a component.
    - CREATE: Create the component resources
    - DELETE: Delete the component resources
    """
    CREATE = "create"
    DELETE = "delete"

class ComponentStrategy(ABC):
    @abstractmethod
    def validate(self, action: ComponentAction, manifests: str) -> None:
        raise NotImplementedError()
    
    @abstractmethod
    def diff(self, action: ComponentAction, manifests: str) -> None:
        raise NotImplementedError()
    
    @abstractmethod
    def do_action(self, action: ComponentAction, manifests: str) -> None:
        raise NotImplementedError()
    
class DiffComponentStrategy(ComponentStrategy):
    """ Uses the kubectl apply method to patch differences in resources.
    """
    _kubectl: KubectlClient

    def __init__(self, kubectl: KubectlClient) -> None:
        super().__init__()
        self._kubectl = kubectl

    def validate(self, action: ComponentAction, manifests: str) -> None:
        kubectl_action = SendManifestsAction.APPLY if action == ComponentAction.CREATE else SendManifestsAction.DELETE
        dry_run_res = self._kubectl.send_manifests_dry_run(kubectl_action, manifests)
        
        if dry_run_res["missing_namespaces"] is not None:
            for ns in dry_run_res['missing_namespaces']:
                logging.warning("Must create namespace: %s", ns)

            logging.warning("Validation might not be accurate because resource(s) were specified in namespace(s) which do not exist")
        
        logging.info("Validated manifests")
    
    def diff(self, action: ComponentAction, manifests: str) -> None:
        if action == ComponentAction.CREATE:
            diff_res = self._kubectl.diff(manifests)

            if diff_res["missing_namespaces"] is not None:
                for ns in diff_res['missing_namespaces']:
                    logging.warning("Must create namespace: %s", ns)

                logging.warning("Diff might not be accurate because resource(s) were specified in namespace(s) which do not exist")

            logging.info("Proposed manifest changes")
            logging.info(diff_res['diff'])
        elif action == ComponentAction.DELETE:
            logging.info("Cannot compute diff for delete, displaying manifests which will be passed to delete command: \n%s", manifests.replace("\\n", "\n"))
    
    def do_action(self, action: ComponentAction, manifests: str) -> None:
        kubectl_action = SendManifestsAction.APPLY if action == ComponentAction.CREATE else SendManifestsAction.DELETE
        apply_res = self._kubectl.send_manifests(kubectl_action, manifests)

        logging.info("%s Kuberenetes manifests", "Applied" if action == "apply" else "Deleted")

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
    namespace: str

INPUT_MANIFEST_HASH_ANNOTATION = "funkyboy.zone/input-manifest-hash"

class BigDiffComponentStrategy(ComponentStrategy):
    """ When resources are created the hash of the input manifest is stored as an annotation. If the hash of the input manifest changes the resource is wholesale created.
    """
    _kubectl: KubectlClient

    def __init__(self, kubectl: KubectlClient) -> None:
        super().__init__()
        self._kubectl = kubectl

    def _hash_dict(self, value: Dict[str, Any]) -> str:
        """ Given a dictionary produce a hash of its contents.
        Arguments:
        - value: To hash

        Returns: Hash
        """
        return str(hash(json.dumps(value, sort_keys=True)))
    
    def _parse_manifests(self, in_manifests: str) -> List[ManifestResource]:
        parsed_manifests = load_all_yaml(in_manifests)

        resources = []

        for manifest_i in range(len(parsed_manifests)):
            parsed_manifest = parsed_manifests[manifest_i]

            # Get namespace
            ns = "default"
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
        outputs = []
        for plan in plans:
            outputs.append(self._kubectl.send_manifests(plan["action"].to_send_manifest_action(), plan["manifest"]))

        return outputs
    
    def _dry_run_plans(self, plans: List[BigDiffPlan]) -> List[KubeDryRunRes]:
        outputs = []
        for plan in plans:
            outputs.append(self._kubectl.send_manifests_dry_run(plan["action"].to_send_manifest_action(), plan["manifest"]))

        return outputs 

    def validate(self, action: ComponentAction, manifests: str) -> None:
        dry_run_results = self._dry_run_plans(self._generate_plans(manifests))
        
        for res in dry_run_results:    
            if res["missing_namespaces"] is not None:
                for ns in res['missing_namespaces']:
                    logging.warning("Must create namespace: %s", ns)

                logging.warning("Validation might not be accurate because resource(s) were specified in namespace(s) which do not exist")
        
        logging.info("Validated manifests")
    
    def diff(self, action: ComponentAction, manifests: str) -> None:
        dry_run_results = self._dry_run_plans(self._generate_plans(manifests))

        for res in dry_run_results:
            if res["missing_namespaces"] is not None:
                for ns in res['missing_namespaces']:
                    logging.warning("Must create namespace: %s", ns)

                logging.warning("Diff might not be accurate because resource(s) were specified in namespace(s) which do not exist")

            logging.info("Proposed manifest changes")
            logging.info(res["output"])
    
    def do_action(self, action: ComponentAction, manifests: str) -> None:
        if action == ComponentAction.CREATE:
            results = self._perform_plans(self._generate_plans(manifests))

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
            res = self._kubectl.send_manifests(SendManifestsAction.DELETE, manifests)

            if res["output"] is None:
                logging.info("not output")
            else:
                for line in res['output'].split("\n"):
                    if "unchanged" in line or len(line.strip()) == 0:
                        continue

                    print(line)