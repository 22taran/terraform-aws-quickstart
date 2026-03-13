variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "project_suffix" {
  description = "Suffix for project name. Defaults to backend when ecr_repository_url provided, else static-deploy."
  type        = string
  default     = null
}

variable "s3_bucket_name" {
  description = "S3 bucket name for static/frontend deploy (when not using ECR)"
  type        = string
  default     = null
}

variable "cloudfront_distribution_id" {
  description = "CloudFront distribution ID for cache invalidation (when s3_bucket_name set)"
  type        = string
  default     = null
}

variable "ecr_repository_url" {
  description = "ECR repository URL for Docker push. When set, treats as backend build (CodePipeline source, ECR output)"
  type        = string
  default     = null
}

variable "ecr_repository_arn" {
  description = "ECR repository ARN for IAM (required when ecr_repository_url set)"
  type        = string
  default     = null
}

variable "codepipeline_artifact_bucket_name" {
  description = "CodePipeline artifact S3 bucket name (required when ecr_repository_url set - source from CodePipeline)"
  type        = string
  default     = null
}

variable "build_output_path" {
  description = "Path to built static files relative to source root (e.g. dist, build, out)"
  type        = string
  default     = "dist"
}

variable "buildspec" {
  description = "Buildspec: inline YAML content, or path (e.g. buildspec.yaml). If empty, uses buildspec.yaml from repo."
  type        = string
  default     = ""
}

variable "source_location" {
  description = "GitHub repo URL for source (when not backend/CodePipeline). Use CodeStar connection for auth."
  type        = string
  default     = ""
}

variable "codestar_connection_arn" {
  description = "CodeStar/CodeConnections ARN for GitHub auth (required when source_location set)"
  type        = string
  default     = null
}

variable "compute_type" {
  description = "CodeBuild compute type"
  type        = string
  default     = "BUILD_GENERAL1_SMALL"
}

variable "image" {
  description = "CodeBuild image (pass from root - e.g. Node for static, Docker-capable for backend)"
  type        = string
  default     = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
}

variable "description" {
  description = "Project description (optional)"
  type        = string
  default     = null
}

variable "service_role_arn" {
  description = "IAM role ARN for CodeBuild project (required)"
  type        = string
}

variable "artifacts_type" {
  description = "Artifacts type: NO_ARTIFACTS, CODEPIPELINE (optional, derived from ecr when null)"
  type        = string
  default     = null
}

variable "git_clone_depth" {
  description = "Git clone depth for non-CodePipeline source (1 = shallow)"
  type        = number
  default     = null
}

variable "log_group_name" {
  description = "CloudWatch log group name (optional)"
  type        = string
  default     = null
}

variable "log_stream_name" {
  description = "CloudWatch log stream name (optional)"
  type        = string
  default     = null
}

variable "build_timeout" {
  description = "Build timeout in minutes"
  type        = number
  default     = 10
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7
}

variable "environment_variables" {
  description = "Environment variables for the build (e.g. VITE_API_URL, VITE_COGNITO_USER_POOL_ID for static; pass from root)"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
