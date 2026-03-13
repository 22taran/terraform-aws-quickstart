# S3 Module

Creates an S3 bucket with optional versioning, public access block, server-side encryption, and CORS configuration. Used for static assets, CloudFront origins, or CodePipeline artifacts.

## Usage

```hcl
module "s3_static" {
  source = "../../modules/s3"

  bucket_name         = "my-project-static-123456789012"
  versioning         = true
  block_public_access = true
  force_destroy      = true
  tags               = var.tags
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bucket_name | Name of the S3 bucket | `string` | n/a | yes |
| force_destroy | Allow bucket destroy with objects (use with caution) | `bool` | `false` | no |
| versioning | Enable versioning on the bucket | `bool` | `true` | no |
| block_public_access | Block all public access | `bool` | `true` | no |
| server_side_encryption | Encryption: AES256, aws:kms, or null | `string` | `null` | no |
| kms_key_id | KMS key ID (required when encryption is aws:kms) | `string` | `null` | no |
| cors_rules | CORS configuration rules | `list(object)` | `[]` | no |
| tags | Tags to apply to the bucket | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| bucket_id | ID of the bucket |
| bucket_name | Name of the bucket |
| bucket_arn | ARN of the bucket |
| bucket_regional_domain_name | Regional domain name (for CloudFront origin) |
