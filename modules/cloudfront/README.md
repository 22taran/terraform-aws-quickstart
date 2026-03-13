# CloudFront Module

Creates a CloudFront distribution with S3 as the default origin for static assets. Optionally adds an ALB origin for API routing (`/api/*`). Configures OAC for S3 access, SPA fallback for 403/404, and attaches an S3 bucket policy for CloudFront access.

## Usage

```hcl
module "cloudfront" {
  source = "../../modules/cloudfront"

  project_name                = "my-project"
  bucket_name                 = module.s3_static.bucket_name
  bucket_arn                  = module.s3_static.bucket_arn
  bucket_regional_domain_name = module.s3_static.bucket_regional_domain_name
  alb_dns_name                = module.alb.alb_dns_name  # null for static-only
  tags                        = var.tags
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project_name | Project name for resource naming | `string` | n/a | yes |
| bucket_name | S3 bucket name for static assets | `string` | n/a | yes |
| bucket_arn | ARN of the S3 bucket | `string` | n/a | yes |
| bucket_regional_domain_name | Regional domain of S3 bucket | `string` | n/a | yes |
| alb_dns_name | ALB DNS for API origin (null = static-only) | `string` | `null` | no |
| default_root_object | Object for root path (SPA) | `string` | `"index.html"` | no |
| price_class | Price class (PriceClass_100, PriceClass_200, PriceClass_All) | `string` | `"PriceClass_100"` | no |
| min_ttl | Minimum cache TTL in seconds | `number` | `0` | no |
| default_ttl | Default cache TTL in seconds | `number` | `3600` | no |
| max_ttl | Maximum cache TTL in seconds | `number` | `86400` | no |
| api_path_pattern | Path pattern for API routing | `string` | `"/api/*"` | no |
| error_response_page | Page for 403/404 (SPA fallback) | `string` | `"/index.html"` | no |
| tags | Tags to apply to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| cloudfront_domain_name | Domain name of the CloudFront distribution |
| cloudfront_hosted_zone_id | Hosted zone ID for Route53 alias |
| cloudfront_distribution_id | ID of the CloudFront distribution |
| cloudfront_url | Full URL (https://domain) |
