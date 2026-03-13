output "cluster_id" {
  description = "ID of the ECS cluster"
  value       = module.ecs.cluster_id
}

output "cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = module.ecs.cluster_arn
}

output "cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.ecs.cluster_name
}
output "service_name" {
  description = "Name of the ECS service"
  value       = module.ecs.services["main"].name
}

output "task_definition_arn" {
  description = "ARN of the task definition"
  value       = module.ecs.services["main"].task_definition_arn
}

output "task_execution_role_arn" {
  description = "ARN of the ECS task execution role"
  value       = module.ecs.services["main"].task_exec_iam_role_arn
}

output "task_role_arn" {
  description = "ARN of the ECS task role"
  value       = module.ecs.services["main"].tasks_iam_role_arn
}
