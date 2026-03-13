# CodePipeline Module

Creates an AWS CodePipeline with GitHub as source (via CodeStar connection) and CodeBuild for the build stage. Optionally adds an ECS deploy stage.

**Stages:**
- **Source**: GitHub via CodeStarSourceConnection
- **Build**: CodeBuild
- **Deploy** (optional): ECS when `deploy_to_ecs = true`

## Usage

```hcl
module "codepipeline" {
  source = "../../modules/codepipeline"

  pipeline_name          = "my-project-backend-pipeline"
  codestar_connection_arn = module.codestar.connection_arn
  repository_id          = module.codestar.backend_repository_id
  codebuild_project_name = module.codebuild_backend.project_name
  artifact_store_bucket  = module.s3_artifacts.bucket_name
  branch_name            = "main"
  deploy_to_ecs          = false  # true adds ECS deploy stage
  tags                   = var.tags
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| pipeline_name | Name of the CodePipeline | `string` | n/a | yes |
| codestar_connection_arn | ARN of CodeStar/CodeConnections connection | `string` | n/a | yes |
| repository_id | GitHub repo in owner/repo format | `string` | n/a | yes |
| codebuild_project_name | Name of the CodeBuild project | `string` | n/a | yes |
| artifact_store_bucket | S3 bucket for pipeline artifacts | `string` | n/a | yes |
| project_name | Project name (for role naming) | `string` | `null` | no |
| branch_name | Branch to build | `string` | `"main"` | no |
| deploy_to_ecs | Include ECS deploy stage | `bool` | `false` | no |
| ecs_cluster_name | ECS cluster name (required when deploy_to_ecs) | `string` | `null` | no |
| ecs_service_name | ECS service name (required when deploy_to_ecs) | `string` | `null` | no |
| pipeline_role_arn | Existing IAM role ARN (null = module creates) | `string` | `null` | no |
| kms_key_alias | KMS key alias for artifact encryption | `string` | `null` | no |
| kms_key_arn | KMS key ARN for artifact encryption | `string` | `null` | no |
| execution_mode | QUEUED or SUPERSEDED | `string` | `"QUEUED"` | no |
| detect_changes | Enable change detection for source | `bool` | `true` | no |
| output_artifact_format | CODE_ZIP or CODEBUILD_CLONE_REF | `string` | `"CODE_ZIP"` | no |
| tags | Tags to apply | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| pipeline_name | Name of the CodePipeline |
| pipeline_arn | ARN of the CodePipeline |
| artifact_bucket_name | Name of the artifact bucket |
