from typing import Any, List

import yaml

class PatchedFullLoader(yaml.FullLoader):
    """ https://github.com/yaml/pyyaml/issues/89
    """
    def __init__(self, input: str):
        super().__init__(input)
        self.yaml_implicit_resolvers = yaml.FullLoader.yaml_implicit_resolvers.copy()
        self.yaml_implicit_resolvers.pop("=")


yaml.Loader.yaml_implicit_resolvers.pop("=")

def load_all_yaml(in_str: str) -> List[Any]:
    return list(yaml.load_all(in_str, Loader=yaml.Loader))