variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "name" {
  description = "Name of the security group"
  type        = string
}

variable "description" {
  description = "Description of the security group"
  type        = string
}

variable "from_port" {
  description = "From port for ingress rule"
  type        = number

  validation {
    condition     = var.from_port >= 0 && var.from_port <= 65535
    error_message = "from_port must be between 0 and 65535."
  }
}

variable "to_port" {
  description = "To port for ingress rule"
  type        = number

  validation {
    condition     = var.to_port >= 0 && var.to_port <= 65535
    error_message = "to_port must be between 0 and 65535."
  }
}

variable "protocol" {
  description = "Protocol for ingress rule (e.g. tcp)"
  type        = string
  default     = "tcp"
}

# Use exactly one of: prefix_list_ids (e.g. ALB/CloudFront) or source_security_group_id (e.g. ECS from ALB, RDS from ECS)
variable "prefix_list_ids" {
  description = "Prefix list IDs for ingress (e.g. CloudFront). Omit when using source_security_group_id."
  type        = list(string)
  default     = []
}

variable "use_source_security_group" {
  description = "When true, add ingress rule from source_security_group_id. Must be plan-time known (not derived from resource output)."
  type        = bool
  default     = false
}

variable "source_security_group_id" {
  description = "Source security group ID for ingress (e.g. allow from ALB). Required when use_source_security_group is true."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
