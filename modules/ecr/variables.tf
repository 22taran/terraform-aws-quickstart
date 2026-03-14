variable "repository_name" {
  description = "Name of the ECR repository"
  type        = string
}

variable "lifecycle_policy_image_count" {
  description = "Maximum number of images to retain in ECR before expiring oldest"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags to apply to the ECR repository"
  type        = map(string)
  default     = {}
}