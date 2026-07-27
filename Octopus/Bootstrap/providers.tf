# Default provider - no space_id means it targets the built-in "Default" space.
# System-level resources (like creating new spaces) are also created through this.
provider "octopusdeploy" {
  address = var.octopus_address
  api_key = var.octopus_api_key
}

# One aliased provider per additional space. Each is scoped to its space via
# space_id, so every resource created through it lands in that space.
provider "octopusdeploy" {
  alias    = "space_2"
  address  = var.octopus_address
  api_key  = var.octopus_api_key
  space_id = octopusdeploy_space.space_2.id
}

provider "octopusdeploy" {
  alias    = "space_3"
  address  = var.octopus_address
  api_key  = var.octopus_api_key
  space_id = octopusdeploy_space.space_3.id
}
