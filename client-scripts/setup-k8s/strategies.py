from abc import ABC, abstractmethod
from enum import Enum
import logging

from .kubectl import KubectlClient

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
        kubectl_action = "apply" if action == ComponentAction.CREATE else "delete"
        dry_run_res = self._kubectl.dry_run(kubectl_action, manifests)
        
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
        kubectl_action = "apply" if action == ComponentAction.CREATE else "delete"
        apply_res = self._kubectl.apply_or_delete(kubectl_action, manifests)

        logging.info("%s Kuberenetes manifests", "Applied" if action == "apply" else "Deleted")

        if apply_res["output"] is None:
            logging.info("not output")
        else:
            for line in apply_res['output'].split("\n"):
                if "unchanged" in line or len(line.strip()) == 0:
                    continue

                print(line)