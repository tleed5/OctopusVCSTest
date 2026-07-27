variable "dockerhub_username" {
  type        = string
  description = "Docker Hub username for the Docker container registry feed. Empty means anonymous."
  default     = ""
}

variable "dockerhub_password" {
  type        = string
  description = "Docker Hub password or access token."
  sensitive   = true
  default     = ""
}

variable "git_username" {
  type        = string
  description = "Username for the Git credential."
}

variable "git_password" {
  type        = string
  description = "Password / personal access token for the Git credential."
  sensitive   = true
}

variable "environments" {
  type        = list(string)
  description = "Environments to create, in deployment order."
  default     = ["dev", "staging", "prod"]
}
