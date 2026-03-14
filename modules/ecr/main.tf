module "ecr" {
  source  = "terraform-aws-modules/ecr/aws"
  version = "~> 2.0"

  repository_name         = var.repository_name
  create_lifecycle_policy = true
  repository_lifecycle_policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 30 images"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = var.lifecycle_policy_image_count
      }
      action = {
        type = "expire" # Expire the oldest images
      }
    }]
  })
  tags = var.tags
}