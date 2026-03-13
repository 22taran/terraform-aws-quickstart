data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  # Infer from variables: ecr_repository_url present = backend (CodePipeline/Docker), else static (S3/CloudFront)
  is_backend = var.ecr_repository_url != null
  is_static  = !local.is_backend

  project_suffix = coalesce(var.project_suffix, local.is_backend ? "backend" : "static-deploy")
  full_name      = "${var.project_name}-${local.project_suffix}"

  # Buildspec: use custom from root if provided, else buildspec.yaml from repo
  buildspec = coalesce(trimspace(var.buildspec), "buildspec.yaml")

  # IAM policy statements - base (logs) + conditional (S3/CloudFront or ECR)
  iam_statements = concat(
    [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ],
    # Static: S3 + CloudFront (when s3_bucket_name provided)
    [for i in range(local.is_static ? 2 : 0) : [
      {
        Effect   = "Allow"
        Action   = ["s3:PutObject", "s3:GetObject", "s3:GetObjectVersion", "s3:DeleteObject", "s3:ListBucket"]
        Resource = ["arn:aws:s3:::${var.s3_bucket_name}", "arn:aws:s3:::${var.s3_bucket_name}/*"]
      },
      {
        Effect   = "Allow"
        Action   = ["cloudfront:CreateInvalidation", "cloudfront:GetInvalidation"]
        Resource = "arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${var.cloudfront_distribution_id}"
      }
    ][i]],
    # Backend: ECR (when ecr_repository_url provided)
    [for i in range(local.is_backend ? 2 : 0) : [
      {
        Effect   = "Allow"
        Action   = ["ecr:GetAuthorizationToken"]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
        Resource = var.ecr_repository_arn
      }
    ][i]],
    # Backend: CodePipeline artifact bucket S3 (only evaluated when used with CodePipeline)
    [for i in range((local.is_backend && var.codepipeline_artifact_bucket_name != null) ? 1 : 0) : {
      Effect = "Allow"
      Action = [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:PutObject",
        "s3:GetBucketLocation",
        "s3:ListBucket"
      ]
      Resource = [
        "arn:aws:s3:::${var.codepipeline_artifact_bucket_name}",
        "arn:aws:s3:::${var.codepipeline_artifact_bucket_name}/*"
      ]
    }],
    # Static: CodeStar connection for GitHub (required when using source_location)
    [for i in range((local.is_static && var.codestar_connection_arn != null && var.codestar_connection_arn != "") ? 1 : 0) : {
      Effect   = "Allow"
      Action   = ["codeconnections:GetConnectionToken", "codeconnections:GetConnection"]
      Resource = [var.codestar_connection_arn]
    }]
  )
}

resource "aws_codebuild_project" "main" {
  name          = local.full_name
  description   = coalesce(var.description, "CodeBuild project ${local.full_name}")
  build_timeout = var.build_timeout
  service_role  = var.service_role_arn

  artifacts {
    type = coalesce(var.artifacts_type, local.is_backend ? "CODEPIPELINE" : "NO_ARTIFACTS")
  }

  environment {
    compute_type                = var.compute_type
    image                       = var.image
    type                        = "LINUX_EC2"
    image_pull_credentials_type = "CODEBUILD"

    dynamic "environment_variable" {
      for_each = var.environment_variables
      content {
        name  = environment_variable.key
        value = environment_variable.value
      }
    }
  }

  source {
    type            = local.is_backend ? "CODEPIPELINE" : "GITHUB"
    buildspec       = local.buildspec
    git_clone_depth = local.is_backend ? null : coalesce(var.git_clone_depth, 1)
    location        = local.is_backend ? null : var.source_location

    dynamic "auth" {
      for_each = (local.is_static && var.codestar_connection_arn != null && var.codestar_connection_arn != "") ? [1] : []
      content {
        type     = "CODECONNECTIONS"
        resource = var.codestar_connection_arn
      }
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = coalesce(var.log_group_name, "/codebuild/${local.full_name}")
      stream_name = coalesce(var.log_stream_name, local.project_suffix)
    }
  }

  tags = merge(var.tags, { Name = local.full_name })
}

resource "aws_cloudwatch_log_group" "codebuild" {
  name              = coalesce(var.log_group_name, "/codebuild/${local.full_name}")
  retention_in_days = var.log_retention_days

  tags = merge(var.tags, { Name = "/codebuild/${local.full_name}" })
}
