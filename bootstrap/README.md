# Bootstrap

Creates the S3 bucket required for Terraform remote state **before** running the main infrastructure. Uses S3 versioning and `use_lockfile` for locking (no DynamoDB). Run once per environment or account.

## Quick Start

```bash
cd bootstrap
cp .env.example .env
# Edit .env with your PROJECT_NAME, ENVIRONMENT, AWS_REGION, etc.
./create-state-bucket.sh
```

## What It Creates

| Resource | Purpose |
|----------|---------|
| **S3 bucket** | Stores Terraform state files |
| **Versioning** | Enables state history and recovery from accidental overwrites |
| **Encryption** | AES-256 (default) or KMS (optional; key rotation, CloudTrail audit) |
| **Block public access** | Denies public access (default, explicit for audit) |
| **DynamoDB table** (optional, `-d`) | State locking for teams with concurrent runs |

The script auto-loads `bootstrap/.env` when run. Bucket name is derived: `terraform-state-{project}-{env}-{timestamp}`.

### .env variables

| Variable | Description |
|----------|-------------|
| `PROJECT_NAME` | **Required.** Project name (match terraform.tfvars) |
| `ENVIRONMENT` | **Required.** Environment: dev, staging, prod |
| `AWS_REGION` | AWS region for state bucket |
| `TF_LOCK_TABLE` | DynamoDB table name (only when `CREATE_LOCK_TABLE=true`) |
| `CREATE_LOCK_TABLE` | `false` = S3-only (default), `true` = add DynamoDB for teams |
| `USE_KMS` | `true` for KMS encryption |

## Prerequisites

- [AWS CLI](https://aws.amazon.com/cli/) installed and configured
- AWS credentials with permissions: `s3:CreateBucket`, `s3:Put*`, `s3:Get*`, `s3:ListBucket`, `kms:*` (if using `-k`), `dynamodb:*` (only if using `-d`)

## Usage

```bash
# With .env (PROJECT_NAME, ENVIRONMENT required)
./create-state-bucket.sh

# Custom region
./create-state-bucket.sh -r us-west-2

# KMS encryption (recommended for production: key rotation, CloudTrail audit)
./create-state-bucket.sh -k

# Add DynamoDB for team locking (when multiple people run terraform)
./create-state-bucket.sh -d

# Via environment variables
PROJECT_NAME=myapp ENVIRONMENT=prod USE_KMS=true ./create-state-bucket.sh
```

## Options

| Option | Env Variable | Default | Description |
|--------|--------------|---------|-------------|
| `-r, --region` | `AWS_REGION` | `us-east-2` | AWS region |
| `-k, --kms` | `USE_KMS=true` | `false` | Use KMS encryption (key rotation, audit trail) |
| `-d, --dynamodb` | `CREATE_LOCK_TABLE=true` | `false` | Create DynamoDB table for team locking |
| `-h, --help` | — | — | Show help |

## After Running

1. Copy the `backend "s3" { ... }` block printed by the script.
2. Paste it into `environments/dev/versions.tf` (or your environment’s `versions.tf`), replacing or updating the existing backend block.
3. Run `terraform init` (or `terraform init -reconfigure` if migrating from local state).

## Bucket Naming

Bucket names are derived as `terraform-state-{project}-{env}-{timestamp}` for global uniqueness. Set `PROJECT_NAME` and `ENVIRONMENT` in `.env`.
