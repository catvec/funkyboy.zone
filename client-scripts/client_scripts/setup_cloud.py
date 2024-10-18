from typing import List, Optional, Union, Literal
import argparse
import yaml
import os

import pydantic
from dotenv import load_dotenv

from lib.logging import logging
from lib.print_diff import print_diff
from setup_cloud.terraform import TerraformClient

# Directories
PROG_DIR = os.path.dirname(os.path.realpath(__file__))
TERRAFORM_PROJECT_DIR = os.path.join(PROG_DIR, "../../terraform")

DEFAULT_PROJECTS_SPEC = os.path.join(TERRAFORM_PROJECT_DIR, "projects.yaml")

# Constants
SUB_CMD_APPLY = "apply"
SUB_CMD_INIT = "init"

class ProjectSpec(pydantic.BaseModel):
    """Specification of project."""
    path: str
    state_file: str

class ProjectsListSpec(pydantic.BaseModel):
    """List of Terraform projects."""
    projects: List[ProjectSpec]

    @classmethod
    def from_yaml_file(cls, file_path: str) -> "ProjectsListSpec":
        with open(file_path, 'r') as f:
            return cls(**yaml.safe_load(f))
        
class DiffConfirmFail(Exception):
    """Indicates user did not affirmatively confirm diff."""
    
    def __init__(self) -> None:
        super().__init__("Did not confirm diff, exiting...")
        
def apply_projects(
    projects_spec_path: str,
    only_projects: Optional[List[str]],
    action: Optional[Union[Literal[SUB_CMD_APPLY], Literal[SUB_CMD_INIT]]]=None,
    init_upgrade: Optional[bool]=None,
    verbose: Optional[bool]=None
) -> None:
    """Apply Terraform projects."""
    # Load projects spec
    logging.info("Loading projects specification {}", projects_spec_path)
    projects_list_spec = ProjectsListSpec.from_yaml_file(projects_spec_path)
    logging.debug("Loaded projects specification")

    projects_spec_dir = os.path.dirname(os.path.realpath(projects_spec_path))

    def normalize_path(path: str) -> str:
        return os.path.normpath(os.path.join(projects_spec_dir, path))
    
    only_projects_normalized = [
        os.path.normpath(os.path.join(os.getcwd(), path))
        for path in only_projects
    ] if only_projects is not None else None

    for project_spec in projects_list_spec.projects:
        if only_projects_normalized is not None and normalize_path(project_spec.path) not in only_projects_normalized:
            logging.debug("Skipping project '{}'", project_spec.path)
            continue

        logging.info("Processing project project '{}'", project_spec.path)
        tf_client = TerraformClient(
            directory=normalize_path(project_spec.path),
            state_file=normalize_path(project_spec.state_file),
            tf_vars_from_env={
                "do_token": "DO_API_TOKEN",
            },
        )

        # Check initialized
        dot_tf_dir = normalize_path(os.path.join(project_spec.path, "./.terraform"))
        if action == SUB_CMD_INIT or not os.path.exists(dot_tf_dir):
            logging.debug("'{}' directory did not exist", dot_tf_dir)

            logging.info("Initializing Terraform (upgrade={})", init_upgrade)
            init_out = tf_client.initialize(upgrade=init_upgrade)

            if verbose:
                logging.info(init_out)

        # Check if just initializing
        if action == SUB_CMD_INIT:
            logging.info("Done running initialize")
            continue

        # Plan
        logging.info("Planning '{}'", project_spec.path)

        plan_res = tf_client.plan()
        
        if plan_res.empty:
            logging.info("No changes required")
        else:
            print_diff(plan_res.human_diff)

            logging.info("Confirm changes [y/N]")
            confirm_in = input().strip().lower()

            if confirm_in != "y":
                raise DiffConfirmFail()   

            # Apply
            logging.info("Applying '{}'", project_spec.path)

            apply_out = tf_client.apply(plan_res.plan_file)    

            logging.info(apply_out)

        os.remove(plan_res.plan_file)

def main():
    """Entrypoint."""
    # Parse arguments
    parser = argparse.ArgumentParser(description="Provision cloud resources")
    parser.add_argument(
        "--projects-spec-path",
        default=DEFAULT_PROJECTS_SPEC,
        help="Path to projects specification YAML file",
    )
    parser.add_argument(
        "--only-project",
        "-o",
        action="append",
        dest="only_projects",
        default=None,
        help="Only apply projects at path",
    )
    parser.add_argument(
        "--verbose",
        action="store_true",
        help="Output additional non-crucial information",
    )

    subcmd_parser = parser.add_subparsers(
        dest="subcmd",
        required=False,
    )
    apply_parser = subcmd_parser.add_parser(
        SUB_CMD_APPLY,
        help="Automatically init, plan (ask for approval), and apply",
    )
    init_parser = subcmd_parser.add_parser(
        SUB_CMD_INIT,
        help="Just initialize terraform",
    )
    init_parser.add_argument(
        "--upgrade",
        action="store_true",
        help="Upgrade providers",
    )

    args = parser.parse_args()

    load_dotenv()

    apply_projects(
        projects_spec_path=args.projects_spec_path,
        only_projects=args.only_projects,
        action=args.subcmd,
        init_upgrade=args.upgrade if args.subcmd == SUB_CMD_INIT else None,
        verbose=args.verbose,
    )

if __name__ == '__main__':
    main()
