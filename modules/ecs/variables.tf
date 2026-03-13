variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "private_subnets" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID for ECS tasks"
  type        = string
}

variable "target_group_arn" {
  description = "ARN of the ALB target group for load balancer integration"
  type        = string
}

variable "container_image" {
  description = "Container image for the ECS task"
  type        = string
}

variable "app_port" {
  description = "Port the application listens on"
  type        = number
  default     = 80
}

variable "health_check_path" {
  description = "Health check path for the container"
  type        = string
  default     = "/"
}

variable "cpu" {
  description = "CPU units for the task (256, 512, 1024, 2048, 4096)"
  type        = number
  default     = 256
}

variable "memory" {
  description = "Memory in MB for the task (512, 1024, 2048, 4096, 8192)"
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Number of tasks to run"
  type        = number
  default     = 1
}

variable "db_endpoint" {
  description = "RDS database endpoint"
  type        = string
}

variable "db_port" {
  description = "RDS database port"
  type        = number
}

variable "db_name" {
  description = "RDS database name"
  type        = string
}

variable "db_username" {
  description = "RDS database username"
  type        = string
}


variable "cognito_user_pool_id" {
  description = "Cognito user pool ID"
  type        = string
}

variable "cognito_client_id" {
  description = "Cognito app client ID"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7
}

variable "extra_environment" {
  description = "Additional environment variables for the container"
  type        = list(object({ name = string, value = string }))
  default     = []
}

variable "db_ssl" {
  description = "Use SSL for database connections"
  type        = bool
  default     = true
}

variable "health_check_interval" {
  description = "Container health check interval in seconds"
  type        = number
  default     = 30
}

variable "health_check_timeout" {
  description = "Container health check timeout in seconds"
  type        = number
  default     = 5
}

variable "health_check_retries" {
  description = "Container health check retry count"
  type        = number
  default     = 3
}

variable "health_check_start_period" {
  description = "Container health check start period in seconds"
  type        = number
  default     = 60
}

variable "db_instance_master_user_secret_arn" {
  description = "ARN of the RDS master user secret"
  type        = string
}

variable "enable_autoscaling" {
  description = "Enable ECS service application auto-scaling (CPU-based)"
  type        = bool
  default     = false
}

variable "autoscaling_min_capacity" {
  description = "Minimum number of ECS tasks when autoscaling is enabled"
  type        = number
  default     = 1
}

variable "autoscaling_max_capacity" {
  description = "Maximum number of ECS tasks when autoscaling is enabled"
  type        = number
  default     = 10
}

variable "autoscaling_target_cpu_percent" {
  description = "Target CPU utilization percentage for ECS autoscaling"
  type        = number
  default     = 70
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
