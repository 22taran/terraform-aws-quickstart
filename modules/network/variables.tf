variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "terraform-vpc"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr must be a valid CIDR block (e.g. 10.0.0.0/16)."
  }
}

variable "azs" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-2a", "us-east-2b", "us-east-2c"]
}

variable "private_subnets" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]

  validation {
    condition     = alltrue([for s in var.private_subnets : can(cidrhost(s, 0))])
    error_message = "Each private_subnets element must be a valid CIDR block."
  }
}

variable "public_subnets" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  validation {
    condition     = alltrue([for s in var.public_subnets : can(cidrhost(s, 0))])
    error_message = "Each public_subnets element must be a valid CIDR block."
  }
}

variable "database_subnets" {
  description = "List of database subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.201.0/24", "10.0.202.0/24", "10.0.203.0/24"]

  validation {
    condition     = alltrue([for s in var.database_subnets : can(cidrhost(s, 0))])
    error_message = "Each database_subnets element must be a valid CIDR block."
  }
}

variable "single_nat_gateway" {
  description = "Use single NAT gateway for all private subnets (cost savings vs one per AZ)"
  type        = bool
  default     = true
}

variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs to CloudWatch Logs for security and troubleshooting"
  type        = bool
  default     = false
}
