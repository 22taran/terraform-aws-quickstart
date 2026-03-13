output "project_name" {
  description = "CodeBuild project name"
  value       = aws_codebuild_project.main.name
}

output "project_arn" {
  description = "CodeBuild project ARN"
  value       = aws_codebuild_project.main.arn
}

output "role_arn" {
  description = "CodeBuild IAM role ARN"
  value       = var.service_role_arn
}
