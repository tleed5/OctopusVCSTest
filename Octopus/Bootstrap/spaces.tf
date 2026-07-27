# The "Default" space already exists in every Octopus instance, so we don't
# create it - we just bootstrap resources into it via the default provider.
#
# space-2 and space-3 are created here (system-level operation) through the
# default provider, then their ids feed the aliased providers in providers.tf.

resource "octopusdeploy_space" "space_2" {
  name                 = "space-2"
  description          = "Development bootstrap space (managed by Terraform)."
  space_managers_teams = ["teams-administrators"]
}

resource "octopusdeploy_space" "space_3" {
  name                 = "space-3"
  description          = "Development bootstrap space (managed by Terraform)."
  space_managers_teams = ["teams-administrators"]
}
