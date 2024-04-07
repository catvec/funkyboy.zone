import subprocess

class TerraformInitError(Exception):
    """Indicates Terraform failed to initialized a project."""

    def __init__(self, directory: str, error: str) -> None:
        super().__init__(f"Failed to initialize Terraform project in '{directory}': {error}")

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

    def initialize(self) -> str:
        """Initialize Terraform project.
        
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

        stdout, stderr = proc.communicate()

        if proc.returncode != 0:
            raise TerraformInitError(
                directory=self.directory,
                error=f"stdout={stdout}, stderr={stderr}"
            )