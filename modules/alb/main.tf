module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "10.5.0"

  name                  = "${var.project_name}-alb"
  load_balancer_type    = "application"
  vpc_id                = var.vpc_id
  subnets               = var.public_subnets
  security_groups       = [var.security_group_id]
  create_security_group = false

  access_logs = var.access_logs_bucket != null ? {
    bucket  = var.access_logs_bucket
    prefix  = var.access_logs_prefix
    enabled = true
  } : {
    bucket  = ""
    prefix  = ""
    enabled = false
  }

  target_groups = {
    main = {
      name_prefix       = substr(var.project_name, 0, min(var.target_group_name_prefix_length, 6))
      protocol          = "HTTP"
      port              = var.app_port
      target_type       = "ip"
      create_attachment = false

      health_check = {
        enabled             = true
        path                = var.health_check_path
        protocol            = "HTTP"
        healthy_threshold   = var.health_check_healthy_threshold
        unhealthy_threshold = var.health_check_unhealthy_threshold
        timeout             = var.health_check_timeout
        interval            = var.health_check_interval
      }
    }
  }

  listeners = {
    http = {
      port     = var.listener_port
      protocol = "HTTP"
      forward = {
        target_group_key = "main"
      }
    }
  }

  tags = merge(var.tags, { Name = "${var.project_name}-alb" })
}
