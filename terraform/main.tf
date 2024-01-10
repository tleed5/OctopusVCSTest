terraform {
  required_providers {
    octopusdeploy = {
      source  = "octopus.com/com/octopusdeploy"
      version = "0.8.995"
    }
  }
}

provider "octopusdeploy" {
  address = "http://localhost:8066"
# This is an api key for my local instance of Octopus
  api_key = "API-6A58D2Y0Y9TLJ3SFFVIHZZ27XXFFHHTM"
}


resource "octopusdeploy_variable" "test_variable" {
  owner_id = "Projects-21"
  type     = "String"
  name     = "Test Process Scope"
  value    = "Scopey"
}
