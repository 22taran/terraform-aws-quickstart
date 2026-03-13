# ECS Module

Creates an ECS Fargate cluster with a service using the [terraform-aws-modules/ecs/aws](https://registry.terraform.io/modules/terraform-aws-modules/ecs/aws) module. Service integrates with ALB target group, RDS (via Secrets Manager), and Cognito.

## Usage

```hcl
module "ecs" {
  source = "../../modules/ecs"

  project_name                       = "my-project"
  cluster_name                       = "my-project-cluster"
  private_subnets                    = module.network.private_subnets
  security_group_id                  = module.security_groups.ecs_sg_id
  target_group_arn                   = module.alb.target_group_arn
  container_image                    = "${module.ecr.repository_url}:latest"
  app_port                           = 80
  health_check_path                  = "/"
  db_endpoint                        = module.rds.db_endpoint
  db_port                            = module.rds.db_port
  db_name                            = module.rds.db_name
  db_username                        = var.db_username
  db_instance_master_user_secret_arn  = module.rds.db_instance_master_user_secret_arn
  cognito_user_pool_id               = module.cognito.user_pool_id
  cognito_client_id                  = module.cognito.app_client_id
  region                             = var.region
  tags                               = var.tags
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project_name | Project name for resource naming | `string` | n/a | yes |
| cluster_name | Name of the ECS cluster | `string` | n/a | yes |
| private_subnets | List of private subnet IDs | `list(string)` | n/a | yes |
| security_group_id | Security group ID for ECS tasks | `string` | n/a | yes |
| target_group_arn | ARN of the ALB target group | `string` | n/a | yes |
| container_image | Container image for the ECS task | `string` | n/a | yes |
| db_endpoint | RDS database endpoint | `string` | n/a | yes |
| db_port | RDS database port | `number` | n/a | yes |
| db_name | RDS database name | `string` | n/a | yes |
| db_username | RDS database username | `string` | n/a | yes |
| db_instance_master_user_secret_arn | ARN of RDS master user secret | `string` | n/a | yes |
| cognito_user_pool_id | Cognito user pool ID | `string` | n/a | yes |
| cognito_client_id | Cognito app client ID | `string` | n/a | yes |
| region | AWS region | `string` | n/a | yes |
| app_port | Port the application listens on | `number` | `80` | no |
| health_check_path | Health check path for the container | `string` | `"/"` | no |
| cpu | CPU units for the task | `number` | `256` | no |
| memory | Memory in MB for the task | `number` | `512` | no |
| desired_count | Number of tasks to run | `number` | `1` | no |
| db_ssl | Use SSL for database connections | `bool` | `true` | no |
| health_check_interval | Container health check interval (seconds) | `number` | `30` | no |
| health_check_timeout | Container health check timeout (seconds) | `number` | `5` | no |
| health_check_retries | Container health check retry count | `number` | `3` | no |
| health_check_start_period | Container health check start period (seconds) | `number` | `60` | no |
| log_retention_days | CloudWatch log retention in days | `number` | `7` | no |
| extra_environment | Additional environment variables | `list(object)` | `[]` | no |
| tags | Tags to apply to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster_id | ID of the ECS cluster |
| cluster_arn | ARN of the ECS cluster |
| service_name | Name of the ECS service |
| task_definition_arn | ARN of the task definition |
