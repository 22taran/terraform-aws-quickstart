output "web_acl_id" {
  description = "ID of the WAFv2 Web ACL"
  value       = aws_wafv2_web_acl.main.id
}

output "web_acl_arn" {
  description = "ARN of the WAFv2 Web ACL (use for CloudFront web_acl_id)"
  value       = aws_wafv2_web_acl.main.arn
}
