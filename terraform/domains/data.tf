data "terraform_remote_state" "compute" {
  backend = "local"

  config = {
    path = "${path.root}/../../secret/terraform/compute/terraform.tfstate"
  }
}