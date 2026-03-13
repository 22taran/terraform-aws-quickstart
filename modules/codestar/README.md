# CodeStar Module

Creates a CodeStar/CodeConnections connection for GitHub. Used as the shared GitHub connection for CodeBuild (static builds) and CodePipeline (backend builds). Parses repository URLs into `owner/repo` format for pipeline configuration.

**Note:** After creation, complete the connection in the AWS Console (GitHub authorization).

## Usage

```hcl
module "codestar" {
  source = "../../modules/codestar"

  project_name            = "my-project"
  frontend_repository_url = "https://github.com/owner/frontend-repo"
  backend_repository_url  = "https://github.com/owner/backend-repo"
  tags                    = var.tags
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project_name | Project name for connection naming | `string` | n/a | yes |
| frontend_repository_url | Frontend GitHub repo URL (CodeBuild static) | `string` | `null` | no |
| backend_repository_url | Backend GitHub repo URL (CodePipeline) | `string` | `null` | no |
| connection_name | Custom connection name (defaults to {project_name}-github) | `string` | `null` | no |
| provider_type | Provider: GitHub or GitHubEnterpriseServer | `string` | `"GitHub"` | no |
| tags | Tags to apply to the connection | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| connection_arn | ARN of the CodeStar connection (for CodeBuild/CodePipeline) |
| connection_id | ID of the connection |
| frontend_repository_url | Passthrough of frontend repo URL |
| frontend_repository_id | Parsed owner/repo for frontend |
| backend_repository_url | Passthrough of backend repo URL |
| backend_repository_id | Parsed owner/repo for CodePipeline FullRepositoryId |
