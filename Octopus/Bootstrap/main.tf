# Bootstrap identical resources into each of the three spaces by instantiating
# the space-bootstrap module once per space, wiring in the space-scoped provider.

module "default_space" {
  source = "./modules/space-bootstrap"

  providers = {
    octopusdeploy = octopusdeploy
  }

  dockerhub_username = var.dockerhub_username
  dockerhub_password = var.dockerhub_password
  git_username       = var.git_username
  git_password       = var.git_password
}

module "space_2" {
  source = "./modules/space-bootstrap"

  providers = {
    octopusdeploy = octopusdeploy.space_2
  }

  dockerhub_username = var.dockerhub_username
  dockerhub_password = var.dockerhub_password
  git_username       = var.git_username
  git_password       = var.git_password
}

module "space_3" {
  source = "./modules/space-bootstrap"

  providers = {
    octopusdeploy = octopusdeploy.space_3
  }

  dockerhub_username = var.dockerhub_username
  dockerhub_password = var.dockerhub_password
  git_username       = var.git_username
  git_password       = var.git_password
}
