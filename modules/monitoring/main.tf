# SNS topic for alarm notifications (e.g. email subscription in prod)
resource "aws_sns_topic" "alarms" {
  name = "${var.project_name}-alarms"
  tags = var.tags
}

# RDS CPU utilization
resource "aws_cloudwatch_metric_alarm" "rds_cpu" {
  alarm_name          = "${var.project_name}-rds-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = var.alarm_period_rds_seconds
  statistic           = "Average"
  threshold           = var.alarm_cpu_rds_threshold_percent

  dimensions = {
    DBInstanceIdentifier = var.rds_instance_id
  }

  alarm_actions = [aws_sns_topic.alarms.arn]
  tags          = var.tags
}

# ECS running count (below min = unhealthy)
resource "aws_cloudwatch_metric_alarm" "ecs_unhealthy" {
  alarm_name          = "${var.project_name}-ecs-unhealthy"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "RunningTaskCount"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = var.alarm_ecs_unhealthy_threshold

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.ecs_service_name
  }

  alarm_actions = [aws_sns_topic.alarms.arn]
  tags          = var.tags
}

# ALB 5xx
resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  alarm_name          = "${var.project_name}-alb-5xx"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = var.alarm_period_alb_seconds
  statistic           = "Sum"
  threshold           = var.alarm_alb_5xx_threshold

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }

  alarm_actions = [aws_sns_topic.alarms.arn]
  tags          = var.tags
}
