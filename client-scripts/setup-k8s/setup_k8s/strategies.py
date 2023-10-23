from abc import ABC, abstractmethod
from enum import Enum
import logging
import json
from typing import Any, Dict, List, TypedDict

import yaml
import jsonpatch

from .kubectl import KubectlClient, SendManifestsAction

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
    PATCH = "patch"

class BigDiffPlan(TypedDict):
    """ Represents what must happen to reconcile differences in a manifest.
    Fields:
    - action: To take
    - manifest: To send to server
    """
    action: BigDiffPlanAction
    manifest: str

class BigDiffComponentStrategy(ComponentStrategy):
    """ Computes the difference in manifests on the client side, saves hash of manifest in an annotation to quickly determine if anything has changed.
    Doesn't prune resources which exist but are left out of manifests.
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
        return str(hash(json.dumps(value, sorted_keys=True)))

    def _hash_yaml_manifests(self, manifests: str) -> List[HashedManifest]:
        """ Given a set of manifests hash each one.
        """
        res = []

        parsed_manifests = yaml.safe_load_all(manifests)
        for manifest in parsed_manifests:
            res.append(HashedManifest(
                manifest=manifest,
                hash=self._hash_dict(manifest),
            ))

        return res
    
    def _generate_plans(self, in_manifests: str) -> List[BigDiffPlan]:
        """ Given a set desired states determine what must be sent to the server to make the remote manifests match.
        """
        plans = []

        in_hashes = self._hash_yaml_manifests(in_manifests)
        for in_hash in in_hashes:
            # Get namespace
            ns = "default"
            if "namespace" in in_hash["manifest"]["metadata"]:
                ns = in_hash["manifest"]["metadata"]["namespace"]

            kind = in_hash["manifest"]["kind"]
            name = in_hash["manifest"]["metadata"]["name"]

            # Get remote resource
            remote_res = self._kubectl.get(ns, kind, name)
            if remote_res is None:
                # Resource doesn't exist, create it
                plans.append(BigDiffPlan(
                    action=BigDiffPlanAction.CREATE,
                    manifest=yaml.dump(in_hash["manifest"]),
                ))
            else:
                patch = jsonpatch.make_patch(remote_res, in_hash["manifest"]).to_string()

                plans.append(BigDiffPlan(
                    action=BigDiffPlanAction.PATCH,
                    manifest=patch,
                ))

        return plans

    def validate(self, action: ComponentAction, manifests: str) -> None:
        dry_run_res = self._kubectl.send_manifests_dry_run(SendManifestsAction.CREATE, manifests)
        
        if dry_run_res["missing_namespaces"] is not None:
            for ns in dry_run_res['missing_namespaces']:
                logging.warning("Must create namespace: %s", ns)

            logging.warning("Validation might not be accurate because resource(s) were specified in namespace(s) which do not exist")
        
        logging.info("Validated manifests")
    
    def diff(self, action: ComponentAction, manifests: str) -> None:
        """ """
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