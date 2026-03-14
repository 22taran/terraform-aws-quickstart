variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "db_subnet_group_name" {
  description = "Name of the database subnet group"
  type        = string
}

variable "security_group_id" {
  description = "Security group ID for the RDS instance"
  type        = string
}

variable "db_name" {
  description = "Name of the database"
  type        = string
}

variable "db_username" {
  description = "Master username for the database"
  type        = string

  validation {
    condition     = length(trimspace(var.db_username)) > 0
    error_message = "db_username must be non-empty."
  }
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "engine_version" {
  description = "PostgreSQL engine version"
  type        = string
  default     = "16"
}

variable "allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 20
}

variable "port" {
  description = "Port the database listens on (PostgreSQL default 5432)"
  type        = number
  default     = 5432

  validation {
    condition     = var.port >= 1 && var.port <= 65535
    error_message = "port must be between 1 and 65535."
  }
}

variable "engine" {
  description = "Database engine (postgres, mysql, etc.)"
  type        = string
  default     = "postgres"
}

variable "family" {
  description = "Database family for parameter group (e.g. postgres16). Derived from engine_version when null"
  type        = string
  default     = null
}

variable "multi_az" {
  description = "Enable Multi-AZ deployment"
  type        = bool
  default     = false
}

variable "storage_encrypted" {
  description = "Encrypt RDS storage at rest"
  type        = bool
  default     = true
}

variable "backup_retention_period" {
  description = "Backup retention period in days"
  type        = number
  default     = 7
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot when destroying"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
