# RDS Module

Creates an Amazon RDS instance using the [terraform-aws-modules/rds/aws](https://registry.terraform.io/modules/terraform-aws-modules/rds/aws) module. Supports PostgreSQL (default) and other engines. Uses Secrets Manager for master password.

## Usage

```hcl
module "rds" {
  source = "../../modules/rds"

  project_name         = "my-project"
  db_subnet_group_name = module.network.database_subnet_group_name
  security_group_id    = module.security_groups.rds_sg_id
  db_name              = "myapp"
  db_username          = "admin"
  instance_class       = "db.t3.micro"
  port                 = 5432
  tags                 = var.tags
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project_name | Project name for resource naming | `string` | n/a | yes |
| db_subnet_group_name | Name of the database subnet group | `string` | n/a | yes |
| security_group_id | Security group ID for the RDS instance | `string` | n/a | yes |
| db_name | Name of the database | `string` | n/a | yes |
| db_username | Master username for the database | `string` | n/a | yes |
| instance_class | RDS instance class | `string` | `"db.t3.micro"` | no |
| engine | Database engine (postgres, mysql, etc.) | `string` | `"postgres"` | no |
| engine_version | Engine version (e.g. 16) | `string` | `"16"` | no |
| allocated_storage | Allocated storage in GB | `number` | `20` | no |
| port | Port the database listens on | `number` | `5432` | no |
| family | Parameter group family (derived from engine_version when null) | `string` | `null` | no |
| multi_az | Enable Multi-AZ deployment | `bool` | `false` | no |
| backup_retention_period | Backup retention period in days | `number` | `7` | no |
| skip_final_snapshot | Skip final snapshot when destroying | `bool` | `true` | no |
| tags | Tags to apply to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| db_endpoint | Connection endpoint for the database |
| db_port | Port the database listens on |
| db_name | Name of the database |
| db_instance_id | ID of the RDS instance |
| db_instance_master_user_secret_arn | ARN of the master user secret in Secrets Manager |
