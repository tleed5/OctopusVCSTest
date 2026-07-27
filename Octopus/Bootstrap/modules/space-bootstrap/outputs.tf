output "environment_ids" {
  description = "Map of environment name to id."
  value       = { for e in octopusdeploy_environment.this : e.name => e.id }
}

output "docker_feed_id" {
  description = "Id of the Docker Hub container registry feed."
  value       = octopusdeploy_docker_container_registry.dockerhub.id
}

output "git_credential_id" {
  description = "Id of the Git credential."
  value       = octopusdeploy_git_credential.this.id
}
