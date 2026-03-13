output "alb_dns_name" {
  description = "DNS name of the load balancer"
  value       = module.alb.dns_name
}

output "alb_arn" {
  description = "ARN of the load balancer"
  value       = module.alb.arn
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = module.alb.target_groups["main"].arn
}

output "production_listener_arn" {
  description = "ARN of the HTTP listener"
  value       = module.alb.listeners["http"].arn
}
