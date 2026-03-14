variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string

  validation {
    condition     = length(trimspace(var.project_name)) > 0
    error_message = "project_name must be non-empty."
  }
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "enable_waf" {
  description = "Enable WAF Web ACL for CloudFront (WAF for CloudFront is created in us-east-1). Set true for production."
  type        = bool
  default     = false
}

variable "force_destroy" {
  description = "Allow S3 buckets to be destroyed even if not empty. Set false for production."
  type        = bool
  default     = true
}

variable "rds_multi_az" {
  description = "Enable RDS Multi-AZ deployment. Set true for production."
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Skip RDS final snapshot when destroying. Set false for production."
  type        = bool
  default     = true
}

variable "ecs_enable_autoscaling" {
  description = "Enable ECS service CPU-based auto-scaling. Set true for production."
  type        = bool
  default     = false
}

variable "ecs_autoscaling_min_capacity" {
  description = "Minimum ECS task count when autoscaling is enabled"
  type        = number
  default     = 1
}

variable "ecs_autoscaling_max_capacity" {
  description = "Maximum ECS task count when autoscaling is enabled"
  type        = number
  default     = 10
}

variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs to CloudWatch. Set true for production."
  type        = bool
  default     = false
}

variable "enable_alb_access_logs" {
  description = "Enable ALB access logs to S3. Set true for production."
  type        = bool
  default     = false
}

variable "enable_cloudwatch_alarms" {
  description = "Create CloudWatch alarms for RDS, ECS, ALB and SNS topic. Set true for production."
  type        = bool
  default     = false
}

# Network
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr must be a valid CIDR (e.g. 10.0.0.0/16)."
  }
}

variable "private_subnets" {
  description = "Private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]

  validation {
    condition     = alltrue([for s in var.private_subnets : can(cidrhost(s, 0))])
    error_message = "Each private_subnets element must be a valid CIDR."
  }
}

variable "public_subnets" {
  description = "Public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  validation {
    condition     = alltrue([for s in var.public_subnets : can(cidrhost(s, 0))])
    error_message = "Each public_subnets element must be a valid CIDR."
  }
}

variable "database_subnets" {
  description = "Database subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.201.0/24", "10.0.202.0/24", "10.0.203.0/24"]

  validation {
    condition     = alltrue([for s in var.database_subnets : can(cidrhost(s, 0))])
    error_message = "Each database_subnets element must be a valid CIDR."
  }
}

variable "single_nat_gateway" {
  description = "Use single NAT gateway (true = cheaper, false = one per AZ)"
  type        = bool
  default     = true
}

# Database
variable "db_name" {
  description = "Name of the database"
  type        = string

  validation {
    condition     = length(trimspace(var.db_name)) > 0
    error_message = "db_name must be non-empty."
  }
}

variable "db_username" {
  description = "Master username for the database"
  type        = string

  validation {
    condition     = length(trimspace(var.db_username)) > 0
    error_message = "db_username must be non-empty."
  }
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_port" {
  description = "Port the RDS database listens on"
  type        = number
  default     = 5432

  validation {
    condition     = var.db_port >= 1 && var.db_port <= 65535
    error_message = "db_port must be between 1 and 65535."
  }
}

# ECS
variable "app_port" {
  description = "Port the application listens on"
  type        = number
  default     = 80

  validation {
    condition     = var.app_port >= 1 && var.app_port <= 65535
    error_message = "app_port must be between 1 and 65535."
  }
}

variable "health_check_path" {
  description = "Health check path for ALB and ECS"
  type        = string
  default     = "/"
}

variable "ecs_cpu" {
  description = "CPU units for the ECS task"
  type        = number
  default     = 512
}

variable "ecs_memory" {
  description = "Memory in MB for the ECS task"
  type        = number
  default     = 1024
}

variable "desired_count" {
  description = "Number of ECS tasks to run (minimum 2 for prod HA)"
  type        = number
  default     = 2
}

# Repositories (full URLs - frontend and backend can be different)
variable "frontend_repository_url" {
  description = "Full GitHub URL for frontend/UI repo (CodeBuild static). E.g. https://github.com/owner/repo"
  type        = string
  default     = ""
}

variable "backend_repository_url" {
  description = "Full GitHub URL for backend repo (CodePipeline Source). E.g. https://github.com/owner/repo. Can be same as frontend for monorepo."
  type        = string
  default     = ""
}

# CodeBuild
variable "codebuild_image_static" {
  description = "CodeBuild image for static/frontend (Node.js, e.g. standard:7.0)"
  type        = string
  default     = "aws/codebuild/ami/amazonlinux-x86_64-base:latest"
}

variable "codebuild_image_backend" {
  description = "CodeBuild image for backend (must have Docker, e.g. standard:7.0)"
  type        = string
  default     = "aws/codebuild/ami/amazonlinux-x86_64-base:latest"
}

variable "backend_dockerfile_path" {
  description = "Path to Dockerfile relative to repo root"
  type        = string
  default     = "backend/Dockerfile"
}

variable "backend_docker_build_context" {
  description = "Docker build context path"
  type        = string
  default     = "backend"
}

variable "static_buildspec" {
  description = "Buildspec for static/frontend build: path (e.g. buildspec.yaml) or inline YAML. Empty = use buildspec.yaml from repo"
  type        = string
  default     = ""
}

variable "backend_buildspec" {
  description = "Buildspec for backend build: path (e.g. buildspec.yaml) or inline YAML. Empty = use buildspec.yaml from repo"
  type        = string
  default     = ""
}

variable "static_build_output_path" {
  description = "Path to built static files"
  type        = string
  default     = "dist"
}

variable "branch_name" {
  description = "Branch to deploy"
  type        = string
  default     = "main"
}

# CodePipeline Backend (Source → Build → Deploy)
variable "backend_pipeline_artifact_bucket" {
  description = "Existing artifact bucket for pipeline (null = S3 module creates one)"
  type        = string
  default     = null
}
