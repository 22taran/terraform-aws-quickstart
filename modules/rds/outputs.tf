output "db_endpoint" {
  description = "Connection endpoint for the database"
  value       = module.rds.db_instance_address
}

output "db_port" {
  description = "Port the database listens on"
  value       = module.rds.db_instance_port
}

output "db_name" {
  description = "Name of the database"
  value       = module.rds.db_instance_name
}

output "db_instance_id" {
  description = "ID of the RDS instance (resource ID)"
  value       = module.rds.db_instance_resource_id
}

output "db_instance_identifier" {
  description = "RDS instance identifier (for CloudWatch dimensions)"
  value       = module.rds.db_instance_identifier
}

output "db_instance_master_user_secret_arn" {
  description = "ARN of the master user secret"
  value       = module.rds.db_instance_master_user_secret_arn
}