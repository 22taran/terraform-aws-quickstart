output "cloudfront_url" {
  description = "URL of the static site (CloudFront)"
  value       = module.cloudfront.cloudfront_url
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  value       = module.cloudfront.cloudfront_domain_name
}

output "alb_url" {
  description = "URL of the API (ALB)"
  value       = "http://${module.alb.alb_dns_name}"
}

output "alb_dns_name" {
  description = "ALB DNS name"
  value       = module.alb.alb_dns_name
}

output "cognito_user_pool_id" {
  description = "Cognito user pool ID (for frontend config)"
  value       = module.cognito.user_pool_id
}

output "cognito_client_id" {
  description = "Cognito app client ID (for frontend config)"
  value       = module.cognito.app_client_id
}

output "rds_endpoint" {
  description = "RDS database endpoint"
  value       = module.rds.db_endpoint
  sensitive   = true
}

output "s3_bucket_name" {
  description = "S3 bucket name for static site uploads"
  value       = module.cloudfront.s3_bucket_name
}

output "codebuild_project_name" {
  description = "CodeBuild project name for static site deployment"
  value       = module.codebuild.project_name
}

output "codestar_connection_arn" {
  description = "CodeStar/CodeConnections ARN (complete GitHub auth in AWS Console)"
  value       = module.codestar.connection_arn
}

output "rds_instance_master_user_secret_arn" {
  description = "ARN of the master user secret"
  value       = module.rds.db_instance_master_user_secret_arn
}