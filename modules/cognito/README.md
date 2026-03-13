# Cognito Module

Creates an Amazon Cognito User Pool and App Client for user authentication. Supports configurable password policy and token validity.

## Usage

```hcl
module "cognito" {
  source = "../../modules/cognito"

  project_name  = "my-project"
  tags          = var.tags
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project_name | Project name for resource naming | `string` | n/a | yes |
| username_attributes | Attributes for username (e.g. email, phone_number) | `list(string)` | `["email"]` | no |
| password_minimum_length | Minimum password length | `number` | `8` | no |
| password_require_lowercase | Require lowercase in password | `bool` | `true` | no |
| password_require_numbers | Require numbers in password | `bool` | `true` | no |
| password_require_symbols | Require symbols in password | `bool` | `true` | no |
| password_require_uppercase | Require uppercase in password | `bool` | `true` | no |
| temporary_password_validity_days | Validity period for temporary passwords | `number` | `7` | no |
| access_token_validity_hours | Access token validity in hours | `number` | `1` | no |
| id_token_validity_hours | ID token validity in hours | `number` | `1` | no |
| refresh_token_validity_days | Refresh token validity in days | `number` | `30` | no |
| tags | Tags to apply to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| user_pool_id | ID of the Cognito User Pool |
| user_pool_arn | ARN of the User Pool |
| user_pool_endpoint | Endpoint URL of the User Pool |
| app_client_id | ID of the App Client |
