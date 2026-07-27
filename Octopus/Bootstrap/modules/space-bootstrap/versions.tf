terraform {
  required_version = ">= 1.5.0"

  required_providers {
    octopusdeploy = {
      source                = "OctopusDeployLabs/octopusdeploy"
      version               = ">= 0.30.0"
      configuration_aliases = [octopusdeploy]
    }
  }
}
