variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "rds_instance_id" {
  description = "RDS DB instance identifier (for CPU alarm)"
  type        = string
}

variable "ecs_cluster_name" {
  description = "ECS cluster name (for service alarm)"
  type        = string
}

variable "ecs_service_name" {
  description = "ECS service name (for running count / unhealthy alarm)"
  type        = string
}

variable "alb_arn_suffix" {
  description = "ALB ARN suffix (e.g. app/name/id) for 5xx alarm. From alb.arn_suffix."
  type        = string
}

variable "alarm_cpu_rds_threshold_percent" {
  description = "RDS CPU alarm threshold (percent)"
  type        = number
  default     = 80
}

variable "alarm_ecs_unhealthy_threshold" {
  description = "ECS unhealthy (running count below) alarm threshold"
  type        = number
  default     = 1
}

variable "alarm_alb_5xx_threshold" {
  description = "ALB 5xx count alarm threshold (sum over 1 min)"
  type        = number
  default     = 5
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
