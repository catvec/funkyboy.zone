from typing import List, Optional
import shutil
import subprocess

from lib.bytes_util import decode_bytes

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
                self.__kustomize_cmd_name = ["kustomize", "--enable-helm"]
            elif shutil.which("kubectl") is not None:
                self.__kustomize_cmd_name = ["kubectl", "kustomize", "--enable-helm"]
            else:
                raise KustomizeBinNotFound()

        return self.__kustomize_cmd_name + args
        

    def build(self, dir: str) -> Optional[str]:
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
        
        return decode_bytes(out[0])
