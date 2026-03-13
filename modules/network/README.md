# Network Module

Creates a VPC with public, private, and database subnets using the [terraform-aws-modules/vpc/aws](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws) module. Configures NAT gateways for private subnet internet access and a database subnet group for RDS.

## Usage

```hcl
module "network" {
  source = "../../modules/network"

  vpc_name           = "my-project-vpc"
  vpc_cidr           = "10.0.0.0/16"
  azs                = ["us-east-2a", "us-east-2b", "us-east-2c"]
  private_subnets    = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  database_subnets   = ["10.0.201.0/24", "10.0.202.0/24", "10.0.203.0/24"]
  single_nat_gateway = true
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| vpc_name | Name of the VPC | `string` | `"terraform-vpc"` | no |
| vpc_cidr | CIDR block for the VPC | `string` | `"10.0.0.0/16"` | no |
| azs | List of availability zones | `list(string)` | `["us-east-2a", "us-east-2b", "us-east-2c"]` | no |
| private_subnets | List of private subnet CIDR blocks | `list(string)` | see variables.tf | no |
| public_subnets | List of public subnet CIDR blocks | `list(string)` | see variables.tf | no |
| database_subnets | List of database subnet CIDR blocks | `list(string)` | see variables.tf | no |
| single_nat_gateway | Use single NAT gateway (cost savings vs one per AZ) | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | ID of the VPC |
| public_subnets | List of public subnet IDs |
| private_subnets | List of private subnet IDs |
| database_subnets | List of database subnet IDs |
| database_subnet_group_name | Name of the database subnet group for RDS |
