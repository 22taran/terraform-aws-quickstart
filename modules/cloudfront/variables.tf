variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "bucket_name" {
  description = "Name of the S3 bucket for static assets (from S3 module)"
  type        = string
}

variable "bucket_arn" {
  description = "ARN of the S3 bucket (from S3 module)"
  type        = string
}

variable "bucket_regional_domain_name" {
  description = "Regional domain name of the S3 bucket for origin (from S3 module)"
  type        = string
}

variable "alb_dns_name" {
  description = "ALB DNS name for API origin (null = static-only, no /api/* routing)"
  type        = string
  default     = null
}

variable "default_root_object" {
  description = "Object to serve for root path (SPA default index.html)"
  type        = string
  default     = "index.html"
}

variable "price_class" {
  description = "CloudFront price class: PriceClass_All, PriceClass_200, PriceClass_100"
  type        = string
  default     = "PriceClass_100"
}

variable "default_ttl" {
  description = "Default cache TTL in seconds"
  type        = number
  default     = 3600
}

variable "min_ttl" {
  description = "Minimum cache TTL in seconds"
  type        = number
  default     = 0
}

variable "max_ttl" {
  description = "Maximum cache TTL in seconds"
  type        = number
  default     = 86400
}

variable "api_path_pattern" {
  description = "Path pattern for API routing to ALB (e.g. /api/*)"
  type        = string
  default     = "/api/*"
}

variable "api_cache_policy_id" {
  description = "CloudFront cache policy ID for API origin (default: CachingDisabled)"
  type        = string
  default     = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
}

variable "api_origin_request_policy_id" {
  description = "CloudFront origin request policy ID for API origin"
  type        = string
  default     = "216adef6-5c7f-47e4-b989-5492eafa07d3"
}

variable "error_response_page" {
  description = "Page to serve for 403/404 (SPA fallback)"
  type        = string
  default     = "/index.html"
}

variable "web_acl_id" {
  description = "WAFv2 Web ACL ARN to associate with CloudFront (optional; WAF for CloudFront must be in us-east-1)"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
