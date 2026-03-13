variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "app_port" {
  description = "Port the ECS application listens on"
  type        = number
  default     = 80
}

variable "db_port" {
  description = "Port the RDS database listens on (PostgreSQL default 5432)"
  type        = number
  default     = 5432
}

variable "alb_ingress_port" {
  description = "Port the ALB accepts traffic on (typically 80 for HTTP)"
  type        = number
  default     = 80
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
