# Ready-to-Deploy AWS Infrastructure for Containerized Applications

Production-grade AWS infrastructure as code for a full three-tier web application: SPA on S3+CloudFront, API on ECS Fargate, Database on RDS, Cognito auth, WAF, Monitoring using CloudWatch and CI/CD via GitHub, Bitbucket, or GitLab.

---

## Architecture

![AWS Infrastructure Diagram](Infrastructure.png)

**Flow:** Users → CloudFront (optional WAF) → S3 (static) or ALB (API) → ECS Fargate → RDS. Cognito handles auth; CodeStar Connections (GitHub, Bitbucket, or GitLab) + CodeBuild/CodePipeline automate deployments.

---

## Benefits

| Benefit | How This Stack Delivers It |
|--------|----------------------------|
| **High availability** | Multi-AZ VPC, ALB across 3 public subnets, ECS tasks in private subnets, optional Multi-AZ RDS |
| **Scalability** | ECS Fargate + optional CPU autoscaling, CloudFront edge caching, managed RDS |
| **Security** | Public/private/DB subnet isolation, SG per tier, WAF for CloudFront, Secrets Manager for DB credentials |
| **Cost control** | Toggles for dev vs prod: single vs per-AZ NAT, optional flow logs, ALB logs, WAF, alarms |
| **Operational simplicity** | Managed services (ECS Fargate, RDS, CloudFront), CloudWatch logs/alarms, SNS alerts |
| **Automation** | VCS (GitHub/Bitbucket/GitLab) → CodeStar Connections → CodeBuild/CodePipeline → ECR + ECS + S3 + CloudFront |

---

## Problems This Solves

- **Downtime & single points of failure** — Multi-AZ layout and optional Multi-AZ RDS reduce impact of AZ-level outages.
- **Fluctuating traffic** — ALB, ECS Fargate, CloudFront, and optional autoscaling handle load changes.
- **Web vulnerabilities** — Optional WAF protects CloudFront against common exploits.
- **Manual ops** — Managed compute, DB, CDN, and CI/CD reduce manual provisioning and patching.
- **Insecure credentials** — Secrets Manager holds DB password; ECS tasks pull it at runtime.
- **Fragmented auth** — Cognito provides sign-up/sign-in; frontend gets tokens, backend verifies them.

---

## What’s Included

| Layer | Components |
|-------|------------|
| **Edge** | CloudFront, optional WAF |
| **Static** | S3 bucket for SPA |
| **Compute** | ALB, ECS Fargate (private subnets) |
| **Data** | RDS in DB subnets, Secrets Manager |
| **Auth** | Cognito user pool + app client |
| **CI/CD** | CodeStar, CodeBuild, CodePipeline, ECR |

---

## Repository Structure

```
├── environments/dev/     # Dev environment (main.tf wires all modules)
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── terraform.tfvars.example
└── modules/             # Reusable modules
    ├── network, security_groups, alb, ecs, rds, cognito
    ├── s3, cloudfront, waf, monitoring, ecr
    └── codestar, iam, codebuild, codepipeline
```

---

## Sample App: Atom Logistic

The stack deploys a sample logistics app (frontend SPA + backend API) from your VCS (GitHub, Bitbucket, or GitLab):

- **Frontend** → CodeBuild → S3 → CloudFront  
- **Backend** → CodePipeline → CodeBuild (Docker) → ECR → ECS Fargate  

Configure `frontend_repository_url` and `backend_repository_url` in `terraform.tfvars`. See [environments/dev/terraform.tfvars.example](environments/dev/terraform.tfvars.example) for all options.

---

## Quick Start

1. **Prerequisites:** AWS account, Terraform CLI, AWS credentials, frontend/backend repos in GitHub, Bitbucket, or GitLab.

2. **Configure:**
   ```bash
   cd environments/dev
   cp terraform.tfvars.example terraform.tfvars
   # Edit: project_name, db_name, db_username, frontend_repository_url, backend_repository_url
   ```

3. **Apply:**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

4. **Post-apply:** Complete the CodeStar Connections setup in the AWS Console so pipelines can access your VCS repos.

5. **Access:** `terraform output cloudfront_url` — open in browser.

---

## Dev vs Prod Toggles

| Variable | Dev default | Prod recommended |
|----------|-------------|------------------|
| `enable_waf` | false | true |
| `rds_multi_az` | false | true |
| `ecs_enable_autoscaling` | false | true |
| `enable_flow_logs` | false | true |
| `enable_alb_access_logs` | false | true |
| `enable_cloudwatch_alarms` | false | true |
| `force_destroy` | true | false |
| `single_nat_gateway` | true | false (one per AZ) |

All toggles are documented in [environments/dev/terraform.tfvars.example](environments/dev/terraform.tfvars.example).

---

## Modules Reference

| Module | Purpose |
|--------|---------|
| [network](modules/network) | VPC, public/private/DB subnets, NAT, flow logs |
| [security_groups](modules/security_groups) | ALB, ECS, RDS SGs |
| [rds](modules/rds) | RDS + Secrets Manager |
| [ecs](modules/ecs) | ECS Fargate cluster + service |
| [alb](modules/alb) | Application Load Balancer |
| [cloudfront](modules/cloudfront) | CDN with S3 + ALB origins |
| [cognito](modules/cognito) | User pool + app client |
| [waf](modules/waf) | CloudFront WAF (us-east-1) |
| [monitoring](modules/monitoring) | CloudWatch alarms + SNS |
| [codestar](modules/codestar), [codebuild](modules/codebuild), [codepipeline](modules/codepipeline) | CI/CD |

Each module has its own README with inputs/outputs.
