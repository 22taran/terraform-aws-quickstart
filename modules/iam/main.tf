data "aws_caller_identity" "current" {}

locals {
  naming_prefix     = var.project_name
  tags              = var.tags
  # CodeBuild creates log groups under /aws/codebuild/<project-name>
  codebuild_log_arn = "arn:aws:logs:*:${data.aws_caller_identity.current.account_id}:log-group:/codebuild/${var.project_name}*"
}

# -----------------------------
# CodePipeline role
# -----------------------------

data "aws_iam_policy_document" "codepipeline_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "codepipeline" {
  name               = "${local.naming_prefix}-pipeline-role"
  assume_role_policy = data.aws_iam_policy_document.codepipeline_assume_role.json

  tags = local.tags
}

data "aws_iam_policy_document" "codepipeline" {
  # S3 artifact bucket access
  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
      "s3:PutObjectAcl",
      "s3:PutObject",
      "s3:ListBucket",
    ]

    resources = [
      "arn:aws:s3:::${var.artifact_bucket_name}",
      "arn:aws:s3:::${var.artifact_bucket_name}/*",
    ]
  }

  # CodeStar connection usage
  statement {
    effect = "Allow"

    actions   = ["codestar-connections:UseConnection"]
    resources = [var.codestar_connection_arn]
  }

  # CodeBuild integration
  statement {
    effect = "Allow"

    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
    ]

    resources = ["*"]
  }

  # ECR read access for ECS deploy stage (GetAuthorizationToken requires "*" per AWS)
  statement {
    effect = "Allow"

    actions = ["ecr:GetAuthorizationToken"]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
    ]

    resources = [var.ecr_repository_arn]
  }

  # ECS deploy actions
  statement {
    effect = "Allow"

    actions = [
      "ecs:DescribeServices",
      "ecs:DescribeTaskDefinition",
      "ecs:RegisterTaskDefinition",
      "ecs:UpdateService",
      "ecs:TagResource",
    ]

    resources = ["*"]
  }

  # Pass ECS roles only
  statement {
    effect = "Allow"

    actions   = ["iam:PassRole"]
    resources = [var.ecs_task_execution_role_arn, var.ecs_task_role_arn]
  }
}

resource "aws_iam_role_policy" "codepipeline" {
  name   = "${local.naming_prefix}-pipeline-policy"
  role   = aws_iam_role.codepipeline.id
  policy = data.aws_iam_policy_document.codepipeline.json
}

# -----------------------------
# CodeBuild frontend role
# -----------------------------

data "aws_iam_policy_document" "codebuild_frontend_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "codebuild_frontend" {
  name               = "${local.naming_prefix}-codebuild-frontend-role"
  assume_role_policy = data.aws_iam_policy_document.codebuild_frontend_assume_role.json

  tags = local.tags
}

data "aws_iam_policy_document" "codebuild_frontend" {
  # Logs
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["*"]
  }

  # S3 static bucket
  statement {
    effect = "Allow"

    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:DeleteObject",
      "s3:ListBucket",
    ]

    resources = [
      "arn:aws:s3:::${var.s3_static_bucket_name}",
      "arn:aws:s3:::${var.s3_static_bucket_name}/*",
    ]
  }

  # CloudFront invalidation
  statement {
    effect = "Allow"

    actions = [
      "cloudfront:CreateInvalidation",
      "cloudfront:GetInvalidation",
    ]

    resources = [
      "arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${var.cloudfront_distribution_id}",
    ]
  }

  # CodeConnections for GitHub auth
  statement {
    effect = "Allow"

    actions = [
      "codeconnections:GetConnectionToken",
      "codeconnections:GetConnection",
    ]

    resources = [var.codestar_connection_arn]
  }
}

resource "aws_iam_role_policy" "codebuild_frontend" {
  name   = "${local.naming_prefix}-codebuild-frontend-policy"
  role   = aws_iam_role.codebuild_frontend.id
  policy = data.aws_iam_policy_document.codebuild_frontend.json
}

# -----------------------------
# CodeBuild backend role
# -----------------------------

data "aws_iam_policy_document" "codebuild_backend_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "codebuild_backend" {
  name               = "${local.naming_prefix}-codebuild-backend-role"
  assume_role_policy = data.aws_iam_policy_document.codebuild_backend_assume_role.json

  tags = local.tags
}

data "aws_iam_policy_document" "codebuild_backend" {
  # Logs (scoped to this project's CodeBuild log groups)
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [local.codebuild_log_arn, "${local.codebuild_log_arn}:*"]
  }

  # ECR push to specific repository (backend)
  # GetAuthorizationToken requires "*" per AWS
  statement {
    effect = "Allow"

    actions = ["ecr:GetAuthorizationToken"]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
    ]

    resources = [var.ecr_repository_arn]
  }

  # S3 artifact bucket used as CodePipeline source
  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:PutObject",
      "s3:GetBucketLocation",
      "s3:ListBucket",
    ]

    resources = [
      "arn:aws:s3:::${var.codepipeline_artifact_bucket_name}",
      "arn:aws:s3:::${var.codepipeline_artifact_bucket_name}/*",
    ]
  }
}

resource "aws_iam_role_policy" "codebuild_backend" {
  name   = "${local.naming_prefix}-codebuild-backend-policy"
  role   = aws_iam_role.codebuild_backend.id
  policy = data.aws_iam_policy_document.codebuild_backend.json
}

