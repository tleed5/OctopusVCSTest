output "spaces" {
  description = "Bootstrapped spaces and the resources created in each."
  value = {
    default = {
      environment_ids   = module.default_space.environment_ids
      docker_feed_id    = module.default_space.docker_feed_id
      git_credential_id = module.default_space.git_credential_id
    }
    "space-2" = {
      space_id          = octopusdeploy_space.space_2.id
      environment_ids   = module.space_2.environment_ids
      docker_feed_id    = module.space_2.docker_feed_id
      git_credential_id = module.space_2.git_credential_id
    }
    "space-3" = {
      space_id          = octopusdeploy_space.space_3.id
      environment_ids   = module.space_3.environment_ids
      docker_feed_id    = module.space_3.docker_feed_id
      git_credential_id = module.space_3.git_credential_id
    }
  }
}
