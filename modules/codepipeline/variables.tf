variable "project_name" {
  description = "Project name for resource naming (bucket, role). Defaults to pipeline_name when not set"
  type        = string
  default     = null
}

variable "pipeline_name" {
  description = "Name of the CodePipeline"
  type        = string
}

variable "codestar_connection_arn" {
  description = "ARN of the CodeStar/CodeConnections connection to GitHub (from codestar module or existing)"
  type        = string
}

variable "repository_id" {
  description = "GitHub repository in owner/repo format (from codestar module backend_repository_id output)"
  type        = string
}

variable "branch_name" {
  description = "Branch to build and deploy"
  type        = string
  default     = "main"
}

variable "codebuild_project_name" {
  description = "Name of the CodeBuild project (from codebuild module)"
  type        = string
}

variable "deploy_to_ecs" {
  description = "Include ECS deploy stage (Source → Build → Deploy). When false, only Source → Build"
  type        = bool
  default     = false
}

variable "ecs_cluster_name" {
  description = "ECS cluster name (required when deploy_to_ecs = true)"
  type        = string
  default     = null
}

variable "ecs_service_name" {
  description = "ECS service name (required when deploy_to_ecs = true)"
  type        = string
  default     = null
}

variable "artifact_store_bucket" {
  description = "S3 bucket name for pipeline artifacts (from S3 module or existing)"
  type        = string
}

variable "pipeline_role_arn" {
  description = "Existing IAM role ARN for pipeline. If null, module creates one"
  type        = string
}

variable "kms_key_alias" {
  description = "KMS key alias for artifact encryption (e.g. alias/myKmsKey). Optional"
  type        = string
  default     = null
}

variable "kms_key_arn" {
  description = "KMS key ARN for artifact encryption. Use instead of kms_key_alias. Optional"
  type        = string
  default     = null
}

variable "execution_mode" {
  description = "Pipeline execution mode: QUEUED or SUPERSEDED"
  type        = string
  default     = "QUEUED"
}

variable "detect_changes" {
  description = "Enable change detection for source"
  type        = bool
  default     = true
}

variable "output_artifact_format" {
  description = "Source output artifact format: CODE_ZIP or CODEBUILD_CLONE_REF"
  type        = string
  default     = "CODE_ZIP"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
