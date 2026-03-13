## IAM Module

This module centralizes IAM roles for:
- CodePipeline backend pipeline
- CodeBuild frontend (static) project
- CodeBuild backend (Docker/ECR) project

ECS task execution and task roles are **not** changed and continue to be created by the ECS module. Their ARNs are passed in only to scope `iam:PassRole` for CodePipeline.

### Inputs

- `project_name` – project naming prefix
- `artifact_bucket_name` – S3 bucket for CodePipeline artifacts
- `codestar_connection_arn` – CodeStar/CodeConnections ARN
- `s3_static_bucket_name` – static frontend S3 bucket
- `cloudfront_distribution_id` – CloudFront distribution ID for invalidations
- `ecr_repository_arn` – backend ECR repository ARN
- `codepipeline_artifact_bucket_name` – S3 bucket used as CodePipeline source for backend build
- `ecs_task_execution_role_arn` – ECS task execution role ARN
- `ecs_task_role_arn` – ECS task role ARN
- `tags` – extra tags for IAM resources

### Outputs

- `codepipeline_role_arn`
- `codebuild_frontend_role_arn`
- `codebuild_backend_role_arn`

