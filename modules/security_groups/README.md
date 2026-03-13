# Security Groups Module

Creates security groups for ALB, ECS, and RDS. ALB allows inbound from CloudFront only; ECS allows from ALB on app port; RDS allows from ECS on database port.

## Usage

```hcl
module "security_groups" {
  source = "../../modules/security_groups"

  vpc_id       = module.network.vpc_id
  project_name = "my-project"
  app_port     = 80
  db_port      = 5432
  tags         = var.tags
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| vpc_id | ID of the VPC | `string` | n/a | yes |
| project_name | Project name for resource naming | `string` | n/a | yes |
| app_port | Port the ECS application listens on | `number` | `80` | no |
| db_port | Port the RDS database listens on | `number` | `5432` | no |
| alb_ingress_port | Port the ALB accepts traffic on | `number` | `80` | no |
| tags | Tags to apply to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| alb_sg_id | ID of the ALB security group |
| ecs_sg_id | ID of the ECS security group |
| rds_sg_id | ID of the RDS security group |
