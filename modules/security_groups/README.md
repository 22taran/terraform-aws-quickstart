# Security Groups Module

Creates a single security group using [terraform-aws-modules/security-group/aws](https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws/latest). Use one module instance per SG. Ingress is either from a **prefix list** (e.g. CloudFront for ALB) or from another **security group** (e.g. ECS from ALB, RDS from ECS).

## Usage

**ALB (prefix list):**
```hcl
module "security_group_alb" {
  source = "../../modules/security_groups"

  vpc_id          = module.network.vpc_id
  project_name    = local.project_name
  name            = "alb"
  description     = "ALB security group"
  from_port       = 80
  to_port         = 80
  protocol        = "tcp"
  prefix_list_ids = [data.aws_ec2_managed_prefix_list.cloudfront.id]
}
```

**ECS (from ALB SG):**
```hcl
module "security_group_ecs" {
  source = "../../modules/security_groups"

  vpc_id                   = module.network.vpc_id
  project_name             = local.project_name
  name                     = "ecs"
  description              = "ECS security group"
  from_port                = var.app_port
  to_port                  = var.app_port
  protocol                 = "tcp"
  source_security_group_id = module.security_group_alb.security_group_id
}
```

**RDS (from ECS SG):** same pattern with `source_security_group_id = module.security_group_ecs.security_group_id`, and `from_port`/`to_port` = db port.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| vpc_id | ID of the VPC | `string` | n/a | yes |
| project_name | Project name for resource naming | `string` | n/a | yes |
| name | Name of the security group | `string` | n/a | yes |
| description | Description of the security group | `string` | n/a | yes |
| from_port | Ingress from port | `number` | n/a | yes |
| to_port | Ingress to port | `number` | n/a | yes |
| protocol | Ingress protocol | `string` | `"tcp"` | no |
| prefix_list_ids | Prefix list IDs for ingress (use for ALB). Omit when using source_security_group_id. | `list(string)` | `[]` | no |
| source_security_group_id | Source SG ID for ingress (use for ECS, RDS). Omit when using prefix_list_ids. | `string` | `null` | no |
| tags | Tags to apply | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| security_group_id | ID of the security group |
| security_group_arn | ARN of the security group |
| security_group_name | Name of the security group |
