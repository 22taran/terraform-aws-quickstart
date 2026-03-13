
module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "~> 7.4.0"

  cluster_name = var.cluster_name

  create_task_exec_iam_role = true
  task_exec_iam_role_name   = "${var.project_name}-ecs-execution-role"
  task_exec_secret_arns     = [var.db_instance_master_user_secret_arn]

  # Cluster capacity providers
  cluster_capacity_providers = ["FARGATE"]
  default_capacity_provider_strategy = {
    FARGATE = {
      weight = 100
      base   = 1
    }
  }
  services = {
    main = {
      cpu    = var.cpu
      memory = var.memory

      desired_count                  = var.desired_count
      launch_type                    = "FARGATE"
      ignore_task_definition_changes = true

      subnet_ids            = var.private_subnets
      security_group_ids    = [var.security_group_id]
      create_security_group = false

      # Secrets Manager access for task execution role (pulls DB_PASSWORD at startup)
      task_exec_secret_arns = [var.db_instance_master_user_secret_arn]

      load_balancer = {
        service = {
          target_group_arn = var.target_group_arn
          container_name   = var.project_name
          container_port   = var.app_port
        }
      }

      container_definitions = {
        (var.project_name) = {
          essential = true
          image     = var.container_image

          portMappings = [
            {
              name          = var.project_name
              containerPort = var.app_port
              hostPort      = var.app_port
              protocol      = "tcp"
            }
          ]

          environment = concat(
            [
              { name = "DB_HOST", value = var.db_endpoint },
              { name = "DB_PORT", value = tostring(var.db_port) },
              { name = "DB_NAME", value = var.db_name },
              { name = "DB_USERNAME", value = var.db_username },
              { name = "DB_SSL", value = tostring(var.db_ssl) },
              { name = "COGNITO_USER_POOL_ID", value = var.cognito_user_pool_id },
              { name = "COGNITO_CLIENT_ID", value = var.cognito_client_id },
              { name = "COGNITO_REGION", value = var.region }
            ]
          )

          secrets = [
            { name = "DB_PASSWORD", valueFrom = "${var.db_instance_master_user_secret_arn}:password::" }
          ]
          # CloudWatch logging
          enable_cloudwatch_logging              = true
          create_cloudwatch_log_group            = true
          cloudwatch_log_group_name              = "/ecs/${var.project_name}"
          cloudwatch_log_group_retention_in_days = var.log_retention_days

          healthCheck = {
            command     = ["CMD-SHELL", "curl -f http://localhost:${var.app_port}${var.health_check_path} || exit 1"]
            interval    = var.health_check_interval
            timeout     = var.health_check_timeout
            retries     = var.health_check_retries
            startPeriod = var.health_check_start_period
          }
        }
      }

      create_tasks_iam_role = true
      tasks_iam_role_name   = "${var.project_name}-ecs-task-role"
    }
  }

  tags = merge(var.tags, { Name = var.cluster_name })
}

# ECS service application auto-scaling (optional)
resource "aws_appautoscaling_target" "main" {
  count = var.enable_autoscaling ? 1 : 0

  max_capacity       = var.autoscaling_max_capacity
  min_capacity       = var.autoscaling_min_capacity
  resource_id        = "service/${module.ecs.cluster_name}/${module.ecs.services["main"].name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "cpu" {
  count = var.enable_autoscaling ? 1 : 0

  name               = "${var.project_name}-ecs-cpu"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.main[0].resource_id
  scalable_dimension = aws_appautoscaling_target.main[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.main[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = var.autoscaling_target_cpu_percent
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}
