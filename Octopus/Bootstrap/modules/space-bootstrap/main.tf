# The octopusdeploy provider passed into this module is already scoped to a
# single space, so every resource below is created inside that space.
# (Provider requirements incl. configuration_aliases live in versions.tf.)

# --- Environments (dev -> staging -> prod) -----------------------------------

resource "octopusdeploy_environment" "this" {
  count = length(var.environments)

  name                         = var.environments[count.index]
  description                  = "Bootstrapped by Terraform."
  allow_dynamic_infrastructure = true
  use_guided_failure           = false
  sort_order                   = count.index
}

# --- Docker Hub package feed -------------------------------------------------

resource "octopusdeploy_docker_container_registry" "dockerhub" {
  name        = "Docker Hub"
  feed_uri    = "https://index.docker.io"
  api_version = "v1"

  # Credentials are only sent when provided; leave blank for an anonymous feed.
  username = var.dockerhub_username != "" ? var.dockerhub_username : null
  password = var.dockerhub_password != "" ? var.dockerhub_password : null
}

# --- Git credential ----------------------------------------------------------

resource "octopusdeploy_git_credential" "this" {
  name        = "Git Credential"
  description = "Bootstrapped by Terraform."
  type        = "UsernamePassword"
  username    = var.git_username
  password    = var.git_password
}
