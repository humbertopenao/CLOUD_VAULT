module "network" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.63.0"

  name                   = var.network_name
  cidr                   = var.network_cidr
  azs                    = length(var.zone_names) == 0 ? slice(data.aws_availability_zones.default.names, 0, 3) : var.zone_names
  public_subnets         = var.public_subnet_cidrs
  private_subnets        = var.private_subnet_cidrs
  tags                   = var.tags
  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false
}

data "aws_availability_zones" "default" {
  state = "available"
}
