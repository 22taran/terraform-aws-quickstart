# ECR Module

Creates an Amazon ECR repository using the [terraform-aws-modules/ecr/aws](https://registry.terraform.io/modules/terraform-aws-modules/ecr/aws) module. Includes lifecycle policy for image cleanup.

## Usage

```hcl
module "ecr" {
  source = "../../modules/ecr"

  repository_name = "my-project-container-image"
  tags            = var.tags
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| repository_name | Name of the ECR repository | `string` | n/a | yes |
| tags | Tags to apply to the ECR repository | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| repository_url | URL of the ECR repository |
| repository_arn | ARN of the ECR repository |
| repository_name | Name of the ECR repository |
