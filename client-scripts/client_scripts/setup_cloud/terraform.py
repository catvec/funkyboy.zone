from typing import Optional
import subprocess
from dataclasses import dataclass
import os

from lib.bytes_util import decode_stdout_stderr

class TerraformInitError(Exception):
    """Indicates Terraform failed to initialized a project."""

    def __init__(self, directory: str, stdout: Optional[str], stderr: Optional[str]) -> None:
        """Initialize."""
        super().__init__(f"Failed to initialize Terraform project in '{directory}': stdout={stdout}, stderr={stderr}")

class TerraformPlanError(Exception):
    """Indicates Terraform failed to plan changes."""

    def __init__(self, directory: str, state_file: str, stdout: Optional[str], stderr: Optional[str]) -> None:
        """Initialize."""
        super().__init__(f"Failed to plan Terraform changes in '{directory}' with state file '{state_file}': stdout={stdout}, stderr={stderr}")

@dataclass
class TerraformPlanResult:
    """Result of Terraform plan operation.
    """
    plan_file: str
    human_diff: Optional[str]
    empty: bool

class TerraformApplyError(Exception):
    """Indicates an error occurred while applying a Terraform plan."""

    def __init__(
        self,
        directory: str,
        state_file: str,
        plan_file: str,
        stdout: Optional[str],
        stderr: Optional[str],
    ) -> None:
        """Initialize."""
        super().__init__(f"Failed to apply Terraform plan: directory={directory}, state_file={state_file}, plan_file={plan_file}, stdout={stdout}, stderr={stderr}")

class TerraformClient:
    """Execute terraform commands.
    
    Fields:
        directory: Path to Terraform project directory
        state_file: Path to state file
    """

    directory: str
    state_file: str

    def __init__(
        self,
        directory: str,
        state_file: str,
    ):
        """Initialize."""
        self.directory = directory
        self.state_file = state_file

    def initialize(self) -> Optional[str]:
        """Initialize Terraform project.

        Returns:
            Output of terraform init command.
        
        Raises:
            TerraformInitError
        """
        proc = subprocess.Popen(
            [
                "terraform",
                f"-chdir={self.directory}",
                "init",
            ],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )

        stdout, stderr = decode_stdout_stderr(proc.communicate())

        if proc.returncode != 0:
            raise TerraformInitError(
                directory=self.directory,
                stdout=stdout,
                stderr=stderr,
            )
        
        return stdout
    
    def plan(self) -> TerraformPlanResult:
        """Plan what changes need to occur to reconcile cloud state differences.
        
        Returns:
            Result of Terraform plan

        Raises:
            TerraformPlanError
        """
        plan_out = os.path.join(self.directory, "terraform.plan")

        proc = subprocess.Popen(
            [
                "terraform",
                f"-chdir={self.directory}",
                "plan",
                "-state",
                self.state_file,
                "-out",
                plan_out,
                "-detailed-exitcode",
            ],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )

        stdout, stderr = decode_stdout_stderr(proc.communicate())

        # -detailed-exitcode changes exit code behavior to be
        # 0 = success w no changes
        # 1 = error
        # 2 = success w changes
        if proc.returncode == 1:
            raise TerraformPlanError(
                directory=self.directory,
                state_file=self.state_file,
                stdout=stdout,
                stderr=stderr,
            )
        
        plan_empty = proc.returncode == 0
        
        return TerraformPlanResult(
            plan_file=plan_out,
            human_diff=stdout,
            empty=plan_empty,
        )
    
    def apply(self, plan_file: str) -> Optional[str]:
        """Provision infrastructure based on plan changes.

        Args:
            plan_file: File containing Terraform plan to execute

        Returns:
            Output of apply

        Raises:
            TerraformApplyError
        """
        proc = subprocess.Popen(
            [
                "terraform",
                f"-chdir={self.directory}",
                "apply",
                "-state", self.state_file,
                plan_file,
            ],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )

        stdout, stderr = decode_stdout_stderr(proc.communicate())

        if proc.returncode != 0:
            raise TerraformApplyError(
                directory=self.directory,
                state_file=self.state_file,
                plan_file=plan_file,
                stdout=stdout,
                stderr=stderr,
            )
        
        return stdout