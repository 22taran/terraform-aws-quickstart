# ALB Module

Creates an Application Load Balancer with a target group for ECS Fargate using the [terraform-aws-modules/alb/aws](https://registry.terraform.io/modules/terraform-aws-modules/alb/aws) module. Listens on HTTP (port 80) and forwards to the application port.

## Usage

```hcl
module "alb" {
  source = "../../modules/alb"

  project_name       = "my-project"
  vpc_id             = module.network.vpc_id
  public_subnets     = module.network.public_subnets
  security_group_id  = module.security_groups.alb_sg_id
  app_port           = 80
  health_check_path  = "/"
  tags               = var.tags
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project_name | Project name for resource naming | `string` | n/a | yes |
| vpc_id | ID of the VPC | `string` | n/a | yes |
| public_subnets | List of public subnet IDs | `list(string)` | n/a | yes |
| security_group_id | Security group ID for the ALB | `string` | n/a | yes |
| app_port | Port the target application listens on | `number` | `80` | no |
| health_check_path | Health check path for the target group | `string` | `"/"` | no |
| listener_port | Port the ALB listener accepts traffic on | `number` | `80` | no |
| health_check_healthy_threshold | Successful checks before healthy | `number` | `2` | no |
| health_check_unhealthy_threshold | Failed checks before unhealthy | `number` | `3` | no |
| health_check_timeout | Health check timeout in seconds | `number` | `5` | no |
| health_check_interval | Health check interval in seconds | `number` | `30` | no |
| target_group_name_prefix_length | Length of project name prefix (max 6) | `number` | `6` | no |
| tags | Tags to apply to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| alb_dns_name | DNS name of the ALB |
| alb_arn | ARN of the ALB |
| target_group_arn | ARN of the target group (for ECS load_balancer) |
| production_listener_arn | ARN of the HTTP listener |
