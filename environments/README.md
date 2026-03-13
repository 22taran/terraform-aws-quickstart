# Environments

Deploy to different environments (dev, stage, prod) with isolated state and configuration.

## Structure

Each environment has its own:
- **State file**: `env/<env>/terraform.tfstate` in S3 (separate per environment)
- **VPC CIDR**: Dev (10.0.0.0/16), Stage (10.1.0.0/16), Prod (10.2.0.0/16) - no overlap in same account
- **Resource sizing**: Dev uses smaller instances; prod uses Multi-AZ RDS, more ECS tasks

## Usage

```bash
# Deploy to dev
cd environments/dev
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
terraform init
terraform plan
terraform apply

# Deploy to stage (when added)
cd environments/stage
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars
terraform init
terraform plan
terraform apply

# Deploy to prod (when added - use strong passwords and real container image)
cd environments/prod
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars
terraform init
terraform plan
terraform apply
```

## Modules

All modules are in `../modules/`. Each has a README with inputs, outputs, and examples:

- [network](../modules/network/README.md)
- [security_groups](../modules/security_groups/README.md)
- [cognito](../modules/cognito/README.md)
- [rds](../modules/rds/README.md)
- [alb](../modules/alb/README.md)
- [ecs](../modules/ecs/README.md)
- [ecr](../modules/ecr/README.md)
- [s3](../modules/s3/README.md)
- [cloudfront](../modules/cloudfront/README.md)
- [codestar](../modules/codestar/README.md)
- [codebuild](../modules/codebuild/README.md)
- [codepipeline](../modules/codepipeline/README.md)

## CI/CD Components

- **CodeBuild**: Builds static site and deploys to S3, invalidates CloudFront. Uses CodeStar connection for GitHub auth.
- **CodePipeline**: Provide `backend_repository_url` in tfvars for GitHub-triggered builds. Supports Source → Build (and optional ECS Deploy with `deploy_to_ecs = true`).
- **CodeStar**: Single GitHub connection used by both CodeBuild and CodePipeline. Complete connection in AWS Console after first apply.

## Environment differences

| Setting              | Dev   | Stage  | Prod   |
|----------------------|-------|--------|--------|
| RDS instance         | t3.micro | t3.small | t3.medium |
| RDS Multi-AZ         | No    | No     | Yes    |
| RDS final snapshot   | Skip  | Skip   | Create |
| ECS CPU/Memory       | 512/1024 | 512/1024 | 512/1024 |
| ECS desired count    | 2     | 2      | 2      |
| VPC CIDR             | 10.0.0.0/16 | 10.1.0.0/16 | 10.2.0.0/16 |
