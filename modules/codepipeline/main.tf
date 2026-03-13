data "aws_caller_identity" "current" {}

locals {
  naming_prefix        = coalesce(var.project_name, var.pipeline_name)
  artifact_bucket_name = var.artifact_store_bucket
  artifact_bucket_arn  = "arn:aws:s3:::${local.artifact_bucket_name}"
  role_arn             = var.pipeline_role_arn
  connection_arn       = var.codestar_connection_arn
  repository_id        = trimspace(var.repository_id)
}

# Optional: Get KMS key for artifact encryption (when using alias)
data "aws_kms_alias" "artifacts" {
  count = var.kms_key_alias != null ? 1 : 0
  name  = var.kms_key_alias
}

# CodePipeline - ensure no empty config values (AWS requires length >= 1)
locals {
  _connection_arn = local.connection_arn
  _repository_id  = local.repository_id
  _branch_name    = trimspace(coalesce(var.branch_name, "main"))
  _codebuild_name = trimspace(var.codebuild_project_name)
  _ecs_cluster    = var.ecs_cluster_name != null ? trimspace(var.ecs_cluster_name) : ""
  _ecs_service    = var.ecs_service_name != null ? trimspace(var.ecs_service_name) : ""
}

# CodePipeline
resource "aws_codepipeline" "main" {
  lifecycle {
    precondition {
      condition     = local._connection_arn != ""
      error_message = "codestar_connection_arn must be a non-empty ARN. Provide it from the codestar module or terraform.tfvars."
    }
    precondition {
      condition     = coalesce(local._repository_id, "") != ""
      error_message = "repository_id cannot be empty. Set backend_repository_url in tfvars."
    }
    precondition {
      condition     = local._codebuild_name != ""
      error_message = "codebuild_project_name cannot be empty."
    }
    precondition {
      condition     = !var.deploy_to_ecs || (local._ecs_cluster != "" && local._ecs_service != "")
      error_message = "ecs_cluster_name and ecs_service_name must be set when deploy_to_ecs is true."
    }
  }
  name           = var.pipeline_name
  role_arn       = local.role_arn
  pipeline_type  = "V2"
  execution_mode = var.execution_mode

  artifact_store {
    location = local.artifact_bucket_name
    type     = "S3"

    dynamic "encryption_key" {
      for_each = (var.kms_key_alias != null || var.kms_key_arn != null) ? [1] : []
      content {
        id   = var.kms_key_arn != null ? var.kms_key_arn : data.aws_kms_alias.artifacts[0].arn
        type = "KMS"
      }
    }
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn        = local._connection_arn
        FullRepositoryId     = local._repository_id
        BranchName           = local._branch_name
        DetectChanges        = tostring(var.detect_changes)
        OutputArtifactFormat = var.output_artifact_format
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = var.deploy_to_ecs ? ["build_output"] : []

      configuration = {
        ProjectName = local._codebuild_name
      }
    }
  }

  dynamic "stage" {
    for_each = var.deploy_to_ecs ? [1] : []
    content {
      name = "Deploy"

      action {
        name            = "Deploy"
        category        = "Deploy"
        owner           = "AWS"
        provider        = "ECS"
        version         = "1"
        input_artifacts = ["build_output"]

        configuration = {
          ClusterName = local._ecs_cluster
          ServiceName = local._ecs_service
        }
      }
    }
  }

  tags = var.tags
}
