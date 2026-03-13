variable "project_name" {
  description = "Project name for connection naming"
  type        = string
}

variable "frontend_repository_url" {
  description = "Frontend GitHub repo URL (for CodeBuild static). Supports https://github.com/o/r, git@github.com:o/r.git, or owner/repo"
  type        = string
  default     = null
}

variable "backend_repository_url" {
  description = "Backend GitHub repo URL (for CodePipeline). Supports https://github.com/o/r, git@github.com:o/r.git, or owner/repo"
  type        = string
  default     = null
}

variable "connection_name" {
  description = "Name for the CodeStar/CodeConnections connection. Defaults to {project_name}-github"
  type        = string
  default     = null
}

variable "provider_type" {
  description = "Provider type: GitHub or GitHubEnterpriseServer"
  type        = string
  default     = "GitHub"
}

variable "tags" {
  description = "Tags to apply to the connection"
  type        = map(string)
  default     = {}
}
