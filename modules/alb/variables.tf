variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID for the ALB"
  type        = string
}

variable "app_port" {
  description = "Port the target application listens on"
  type        = number
  default     = 80

  validation {
    condition     = var.app_port >= 1 && var.app_port <= 65535
    error_message = "app_port must be between 1 and 65535."
  }
}

variable "health_check_path" {
  description = "Health check path for the target group"
  type        = string
  default     = "/"
}

variable "listener_port" {
  description = "Port the ALB listener accepts traffic on (typically 80 for HTTP)"
  type        = number
  default     = 80

  validation {
    condition     = var.listener_port >= 1 && var.listener_port <= 65535
    error_message = "listener_port must be between 1 and 65535."
  }
}

variable "health_check_healthy_threshold" {
  description = "Number of successful checks before considering target healthy"
  type        = number
  default     = 2
}

variable "health_check_unhealthy_threshold" {
  description = "Number of failed checks before considering target unhealthy"
  type        = number
  default     = 3
}

variable "health_check_timeout" {
  description = "Health check timeout in seconds"
  type        = number
  default     = 5
}

variable "health_check_interval" {
  description = "Health check interval in seconds"
  type        = number
  default     = 30
}

variable "target_group_name_prefix_length" {
  description = "Length of project name used for target group name prefix (max 6)"
  type        = number
  default     = 6
}

variable "access_logs_bucket" {
  description = "S3 bucket name for ALB access logs (null = disabled). Bucket must have a policy allowing elb.amazonaws.com to write."
  type        = string
  default     = null
}

variable "access_logs_prefix" {
  description = "S3 prefix for ALB access logs"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
