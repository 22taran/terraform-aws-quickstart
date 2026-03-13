variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "tags" {
  description = "Tags to apply to WAF resources"
  type        = map(string)
  default     = {}
}
