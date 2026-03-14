module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "${var.project_name}-${var.name}-sg"
  description = var.description
  vpc_id      = var.vpc_id

  # Ingress from prefix list (e.g. CloudFront for ALB). Supports multiple IDs as separate rules.
  ingress_with_prefix_list_ids = [for id in var.prefix_list_ids : {
    from_port       = var.from_port
    to_port         = var.to_port
    protocol        = var.protocol
    description     = var.description
    prefix_list_ids = id
  }]

  # Ingress from another security group (e.g. ECS from ALB, RDS from ECS).
  # use_source_security_group must be a plan-time bool so count is known; source_security_group_id can be computed.
  ingress_with_source_security_group_id = var.use_source_security_group ? [{
    from_port                = var.from_port
    to_port                  = var.to_port
    protocol                 = var.protocol
    description              = var.description
    source_security_group_id = var.source_security_group_id
  }] : []

  egress_rules = ["all-all"]
  tags         = var.tags
}
