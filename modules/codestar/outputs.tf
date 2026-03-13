output "connection_arn" {
  description = "ARN of the CodeStar/CodeConnections connection for GitHub"
  value       = aws_codestarconnections_connection.this.arn
}

output "connection_id" {
  description = "ID of the CodeStar connection"
  value       = aws_codestarconnections_connection.this.id
}

output "frontend_repository_url" {
  description = "Frontend repo URL (passthrough) for CodeBuild source_location"
  value       = var.frontend_repository_url
}

output "frontend_repository_id" {
  description = "Frontend repo in owner/repo format (parsed)"
  value       = var.frontend_repository_url != null && var.frontend_repository_url != "" ? trimspace(replace(replace(replace(var.frontend_repository_url, "https://github.com/", ""), "git@github.com:", ""), ".git", "")) : null
}

output "backend_repository_url" {
  description = "Backend repo URL (passthrough) for CodePipeline"
  value       = var.backend_repository_url
}

output "backend_repository_id" {
  description = "Backend repo in owner/repo format (parsed) for CodePipeline FullRepositoryId"
  value       = var.backend_repository_url != null && var.backend_repository_url != "" ? trimspace(replace(replace(replace(var.backend_repository_url, "https://github.com/", ""), "git@github.com:", ""), ".git", "")) : null
}
