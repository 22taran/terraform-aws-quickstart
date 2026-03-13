variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "force_destroy" {
  description = "Allow bucket to be destroyed even if it has objects (use with caution)"
  type        = bool
  default     = false
}

variable "versioning" {
  description = "Enable versioning on the bucket"
  type        = bool
  default     = true
}

variable "block_public_access" {
  description = "Block all public access to the bucket"
  type        = bool
  default     = true
}

variable "server_side_encryption" {
  description = "Server-side encryption algorithm: AES256, aws:kms, or null for none"
  type        = string
  default     = null
}

variable "kms_key_id" {
  description = "KMS key ID or ARN for encryption (required when server_side_encryption is aws:kms)"
  type        = string
  default     = null
}

variable "cors_rules" {
  description = "CORS configuration rules"
  type = list(object({
    allowed_headers = optional(list(string), ["*"])
    allowed_methods = list(string)
    allowed_origins = list(string)
    expose_headers  = optional(list(string))
    max_age_seconds = optional(number)
  }))
  default = []
}

variable "tags" {
  description = "Tags to apply to the bucket"
  type        = map(string)
  default     = {}
}
