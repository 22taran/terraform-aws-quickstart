variable "project_name" {
  description = "Project name for IAM resource naming"
  type        = string
}

variable "artifact_bucket_name" {
  description = "S3 bucket name for CodePipeline artifacts"
  type        = string
}

variable "codestar_connection_arn" {
  description = "CodeStar/CodeConnections ARN used by CodePipeline and CodeBuild"
  type        = string
}

variable "s3_static_bucket_name" {
  description = "S3 bucket name for static frontend deploy"
  type        = string
}

variable "cloudfront_distribution_id" {
  description = "CloudFront distribution ID for frontend cache invalidation"
  type        = string
}

variable "ecr_repository_arn" {
  description = "ECR repository ARN for backend image pushes"
  type        = string
}

variable "codepipeline_artifact_bucket_name" {
  description = "S3 bucket used as CodePipeline source artifact bucket for backend build"
  type        = string
}

variable "ecs_task_execution_role_arn" {
  description = "ARN of the ECS task execution role used by the service"
  type        = string
}

variable "ecs_task_role_arn" {
  description = "ARN of the ECS task role used by the service"
  type        = string
}

variable "tags" {
  description = "Extra tags to apply to IAM resources"
  type        = map(string)
  default     = {}
}

