variable "octopus_address" {
  type        = string
  description = "Base URL of the local Octopus Deploy instance."
  default     = "http://localhost:8065"
}

variable "octopus_api_key" {
  type        = string
  description = "Octopus API key (API-XXXX...). Passed via tfvars - never commit this."
  sensitive   = true
}

# --- Docker Hub feed credentials ---------------------------------------------

variable "dockerhub_username" {
  type        = string
  description = "Docker Hub username used to authenticate the Docker container registry feed. Leave empty for an anonymous feed."
  default     = ""
}

variable "dockerhub_password" {
  type        = string
  description = "Docker Hub password or access token. Passed via tfvars - never commit this."
  sensitive   = true
  default     = ""
}

# --- Git credential ----------------------------------------------------------

variable "git_username" {
  type        = string
  description = "Username for the Git credential (e.g. a GitHub username or PAT owner)."
}

variable "git_password" {
  type        = string
  description = "Password / personal access token for the Git credential. Passed via tfvars - never commit this."
  sensitive   = true
}
