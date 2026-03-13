# CodeBuild Module

Creates a CodeBuild project that supports two modes:

- **Static/frontend**: GitHub source (via CodeStar), builds assets, deploys to S3, invalidates CloudFront
- **Backend**: CodePipeline source, builds Docker image, pushes to ECR

Mode is inferred from `ecr_repository_url`: when set = backend; when null = static.

## Usage

### Static build (frontend)

```hcl
module "codebuild" {
  source = "../../modules/codebuild"

  project_name              = "my-project"
  s3_bucket_name            = module.s3_static.bucket_name
  cloudfront_distribution_id = module.cloudfront.cloudfront_distribution_id
  source_location           = module.codestar.frontend_repository_url
  codestar_connection_arn    = module.codestar.connection_arn
  image                     = "aws/codebuild/standard:7.0"
  environment_variables     = {
    VITE_API_URL              = module.cloudfront.cloudfront_url
    VITE_COGNITO_USER_POOL_ID = module.cognito.user_pool_id
    VITE_COGNITO_CLIENT_ID    = module.cognito.app_client_id
    S3_BUCKET                 = module.s3_static.bucket_name
    CLOUDFRONT_ID             = module.cloudfront.cloudfront_distribution_id
  }
  tags = var.tags
}
```

### Backend build (CodePipeline)

```hcl
module "codebuild_backend" {
  source = "../../modules/codebuild"

  project_name                      = "my-project"
  project_suffix                    = "backend"
  ecr_repository_url                = module.ecr.repository_url
  ecr_repository_arn                = module.ecr.repository_arn
  codepipeline_artifact_bucket_name = module.s3_artifacts.bucket_name
  image                             = "aws/codebuild/standard:7.0"
  environment_variables             = {
    ECR_URI             = module.ecr.repository_url
    CONTAINER_NAME       = local.project_name
    DOCKERFILE_PATH      = "backend/Dockerfile"
    DOCKER_BUILD_CONTEXT = "backend"
  }
  tags = var.tags
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project_name | Project name for resource naming | `string` | n/a | yes |
| s3_bucket_name | S3 bucket for static deploy (static mode) | `string` | `null` | no |
| cloudfront_distribution_id | CloudFront ID for invalidation (static mode) | `string` | `null` | no |
| ecr_repository_url | ECR URL (when set = backend mode) | `string` | `null` | no |
| ecr_repository_arn | ECR ARN for IAM (backend mode) | `string` | `null` | no |
| codepipeline_artifact_bucket_name | Artifact bucket (backend + CodePipeline) | `string` | `null` | no |
| source_location | GitHub repo URL (static mode) | `string` | `""` | no |
| codestar_connection_arn | CodeStar ARN for GitHub (static mode) | `string` | `null` | no |
| project_suffix | Name suffix (defaults: backend or static-deploy) | `string` | `null` | no |
| buildspec | Buildspec path or inline YAML | `string` | `""` (uses buildspec.yaml) | no |
| build_output_path | Path to built static files | `string` | `"dist"` | no |
| compute_type | CodeBuild compute type | `string` | `"BUILD_GENERAL1_SMALL"` | no |
| image | CodeBuild image | `string` | see variables.tf | no |
| build_timeout | Build timeout in minutes | `number` | `10` | no |
| environment_variables | Environment variables for the build | `map(string)` | `{}` | no |
| git_clone_depth | Git clone depth (static mode) | `number` | `null` | no |
| tags | Tags to apply | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| project_name | Name of the CodeBuild project |
| project_arn | ARN of the CodeBuild project |
| role_arn | ARN of the CodeBuild IAM role |
