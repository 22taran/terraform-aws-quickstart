data "aws_caller_identity" "current" {}

locals {
  project_name = "${var.project_name}-${var.environment}"
}

# Network
module "network" {
  source = "../../modules/network"

  vpc_name           = "${local.project_name}-vpc"
  vpc_cidr           = var.vpc_cidr
  azs                = ["${var.region}a", "${var.region}b", "${var.region}c"]
  private_subnets    = var.private_subnets
  public_subnets     = var.public_subnets
  database_subnets   = var.database_subnets
  single_nat_gateway = var.single_nat_gateway
  enable_flow_logs   = var.enable_flow_logs
}

# Security Groups
module "security_groups" {
  source = "../../modules/security_groups"

  vpc_id       = module.network.vpc_id
  project_name = local.project_name
  app_port     = var.app_port
  db_port      = var.db_port
}

# Cognito
module "cognito" {
  source = "../../modules/cognito"

  project_name = local.project_name
}

# RDS
module "rds" {
  source = "../../modules/rds"

  project_name         = local.project_name
  db_subnet_group_name = module.network.database_subnet_group_name
  security_group_id    = module.security_groups.rds_sg_id
  db_name              = var.db_name
  db_username          = var.db_username
  instance_class       = var.db_instance_class
  port                 = var.db_port
  multi_az             = var.rds_multi_az
  skip_final_snapshot  = var.skip_final_snapshot
}

# S3 bucket for ALB access logs (optional; required for enable_alb_access_logs). Must use SSE-S3 per AWS.
resource "aws_s3_bucket" "alb_logs" {
  count = var.enable_alb_access_logs ? 1 : 0

  bucket = "${local.project_name}-alb-logs-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "alb_logs" {
  count = var.enable_alb_access_logs ? 1 : 0

  bucket = aws_s3_bucket.alb_logs[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "alb_logs" {
  count = var.enable_alb_access_logs ? 1 : 0

  bucket = aws_s3_bucket.alb_logs[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "alb_logs" {
  count = var.enable_alb_access_logs ? 1 : 0

  bucket = aws_s3_bucket.alb_logs[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "logdelivery.elasticloadbalancing.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.alb_logs[0].arn}/alb/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
      }
    ]
  })
}

# ALB
module "alb" {
  source = "../../modules/alb"

  project_name       = local.project_name
  vpc_id             = module.network.vpc_id
  public_subnets     = module.network.public_subnets
  security_group_id  = module.security_groups.alb_sg_id
  app_port           = var.app_port
  health_check_path  = var.health_check_path
  access_logs_bucket = var.enable_alb_access_logs ? aws_s3_bucket.alb_logs[0].id : null
  access_logs_prefix = "alb"
}

# CloudWatch alarms + SNS (optional)
module "monitoring" {
  count  = var.enable_cloudwatch_alarms ? 1 : 0
  source = "../../modules/monitoring"

  project_name     = local.project_name
  rds_instance_id  = module.rds.db_instance_identifier
  ecs_cluster_name = module.ecs.cluster_name
  ecs_service_name = module.ecs.service_name
  alb_arn_suffix   = regex("loadbalancer/(.+)", module.alb.alb_arn)[0]
}

# ECS
module "ecs" {
  source = "../../modules/ecs"

  project_name                       = local.project_name
  cluster_name                       = "${local.project_name}-cluster"
  private_subnets                    = module.network.private_subnets
  security_group_id                  = module.security_groups.ecs_sg_id
  target_group_arn                   = module.alb.target_group_arn
  container_image                    = "${module.ecr.repository_url}:latest"
  app_port                           = var.app_port
  health_check_path                  = var.health_check_path
  cpu                                = var.ecs_cpu
  memory                             = var.ecs_memory
  desired_count                      = var.desired_count
  db_endpoint                        = module.rds.db_endpoint
  db_port                            = module.rds.db_port
  db_name                            = module.rds.db_name
  db_username                        = var.db_username
  db_instance_master_user_secret_arn = module.rds.db_instance_master_user_secret_arn
  cognito_user_pool_id               = module.cognito.user_pool_id
  cognito_client_id                  = module.cognito.app_client_id
  region                             = var.region
  enable_autoscaling                 = var.ecs_enable_autoscaling
  autoscaling_min_capacity           = var.ecs_autoscaling_min_capacity
  autoscaling_max_capacity           = var.ecs_autoscaling_max_capacity
}

module "ecr" {
  source          = "../../modules/ecr"
  repository_name = "${local.project_name}-container-image"
}

# S3 bucket for static site (CloudFront origin + CodeBuild deploy)
module "s3_static" {
  source = "../../modules/s3"

  bucket_name            = "${local.project_name}-static-${data.aws_caller_identity.current.account_id}"
  versioning             = true
  block_public_access    = true
  server_side_encryption = "AES256"
  force_destroy          = var.force_destroy
}

# S3 bucket for CodePipeline artifacts (when not using existing)
module "s3_artifacts" {
  count  = var.backend_pipeline_artifact_bucket == null ? 1 : 0
  source = "../../modules/s3"

  bucket_name            = "${local.project_name}-pipeline-artifacts-${data.aws_caller_identity.current.account_id}"
  versioning             = true
  block_public_access    = true
  server_side_encryption = "AES256"
  force_destroy          = var.force_destroy
}

# WAF (optional; CloudFront scope must be in us-east-1)
module "waf" {
  count  = var.enable_waf ? 1 : 0
  source = "../../modules/waf"

  project_name = local.project_name

  providers = {
    aws = aws.us_east_1
  }
}

# CloudFront distribution
module "cloudfront" {
  source = "../../modules/cloudfront"

  project_name                = local.project_name
  bucket_name                 = module.s3_static.bucket_name
  bucket_arn                  = module.s3_static.bucket_arn
  bucket_regional_domain_name = module.s3_static.bucket_regional_domain_name
  alb_dns_name                = module.alb.alb_dns_name
  web_acl_id                  = var.enable_waf ? module.waf[0].web_acl_arn : null
}


# CodeStar/CodeConnections - central GitHub config; passes connection ARN and repo refs to CodeBuild and CodePipeline
module "codestar" {
  source = "../../modules/codestar"

  project_name            = local.project_name
  frontend_repository_url = var.frontend_repository_url
  backend_repository_url  = var.backend_repository_url
}

# IAM roles for CodePipeline and CodeBuild
module "iam" {
  source = "../../modules/iam"

  project_name                      = local.project_name
  artifact_bucket_name              = var.backend_pipeline_artifact_bucket != null ? var.backend_pipeline_artifact_bucket : module.s3_artifacts[0].bucket_name
  codestar_connection_arn           = module.codestar.connection_arn
  s3_static_bucket_name             = module.s3_static.bucket_name
  cloudfront_distribution_id        = module.cloudfront.cloudfront_distribution_id
  ecr_repository_arn                = module.ecr.repository_arn
  codepipeline_artifact_bucket_name = var.backend_pipeline_artifact_bucket != null ? var.backend_pipeline_artifact_bucket : module.s3_artifacts[0].bucket_name
  ecs_task_execution_role_arn       = module.ecs.task_execution_role_arn
  ecs_task_role_arn                 = module.ecs.task_role_arn
}

# CodeBuild for static site (no ecr = static/frontend)
module "codebuild" {
  source = "../../modules/codebuild"

  project_name               = local.project_name
  s3_bucket_name             = module.s3_static.bucket_name
  cloudfront_distribution_id = module.cloudfront.cloudfront_distribution_id
  buildspec                  = var.static_buildspec
  build_output_path          = var.static_build_output_path
  source_location            = module.codestar.frontend_repository_url
  codestar_connection_arn    = module.codestar.connection_arn
  image                      = var.codebuild_image_static
  service_role_arn           = module.iam.codebuild_frontend_role_arn
  environment_variables = {
    VITE_API_URL              = module.cloudfront.cloudfront_url
    VITE_COGNITO_USER_POOL_ID = module.cognito.user_pool_id
    VITE_COGNITO_CLIENT_ID    = module.cognito.app_client_id
    S3_BUCKET                 = module.s3_static.bucket_name
    CLOUDFRONT_ID             = module.cloudfront.cloudfront_distribution_id
    BUILD_OUTPUT_PATH         = var.static_build_output_path
  }
}

# CodeBuild for backend (ecr_repository_url present = backend/CodePipeline)
module "codebuild_backend" {
  source = "../../modules/codebuild"

  project_name                      = local.project_name
  project_suffix                    = "backend"
  buildspec                         = var.backend_buildspec
  image                             = var.codebuild_image_backend
  ecr_repository_url                = module.ecr.repository_url
  ecr_repository_arn                = module.ecr.repository_arn
  codepipeline_artifact_bucket_name = var.backend_pipeline_artifact_bucket != null ? var.backend_pipeline_artifact_bucket : module.s3_artifacts[0].bucket_name
  service_role_arn                  = module.iam.codebuild_backend_role_arn

  environment_variables = {
    ECR_URI              = module.ecr.repository_url
    CONTAINER_NAME       = local.project_name
    DOCKERFILE_PATH      = var.backend_dockerfile_path
    DOCKER_BUILD_CONTEXT = var.backend_docker_build_context
  }
}

# CodePipeline for backend (Source → Build → Deploy)
module "codepipeline" {
  source = "../../modules/codepipeline"

  project_name            = local.project_name
  pipeline_name           = "${local.project_name}-backend-pipeline"
  codestar_connection_arn = module.codestar.connection_arn
  repository_id           = module.codestar.backend_repository_id
  branch_name             = var.branch_name
  codebuild_project_name  = module.codebuild_backend.project_name
  artifact_store_bucket   = var.backend_pipeline_artifact_bucket != null ? var.backend_pipeline_artifact_bucket : module.s3_artifacts[0].bucket_name
  deploy_to_ecs           = true
  ecs_cluster_name        = module.ecs.cluster_name
  ecs_service_name        = module.ecs.service_name
  pipeline_role_arn       = module.iam.codepipeline_role_arn
}
