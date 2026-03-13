module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.6.0"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs                                = var.azs
  private_subnets                    = var.private_subnets
  public_subnets                     = var.public_subnets
  database_subnets                   = var.database_subnets
  enable_nat_gateway                 = true
  nat_gateway_tags                   = {
    Name = "${var.vpc_name}-nat-gateway"
  }
  igw_tags              = {
    Name = "${var.vpc_name}-igw"
  }
  single_nat_gateway                 = var.single_nat_gateway
  create_database_subnet_group       = true
  create_database_subnet_route_table = true

  enable_flow_log          = var.enable_flow_logs
  flow_log_destination_type = var.enable_flow_logs ? "cloud-watch-logs" : null
}

