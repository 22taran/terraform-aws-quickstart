output "codepipeline_role_arn" {
  description = "IAM role ARN for CodePipeline"
  value       = aws_iam_role.codepipeline.arn
}

output "codebuild_frontend_role_arn" {
  description = "IAM role ARN for CodeBuild frontend/static project"
  value       = aws_iam_role.codebuild_frontend.arn
}

output "codebuild_backend_role_arn" {
  description = "IAM role ARN for CodeBuild backend project"
  value       = aws_iam_role.codebuild_backend.arn
}

