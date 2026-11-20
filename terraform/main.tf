data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  availability_zones = slice(data.aws_availability_zones.available.names, 0, 2)
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Purpose     = "PersonalPortfolio"
  }
}

# checkov:skip=CKV2_AWS_11:Flow Logs are intentionally excluded from the no-cost v1 blueprint and documented as a production enhancement.
# checkov:skip=CKV2_AWS_5:The module exposes a reusable application SG but creates no EC2 or ENI resources by design.
module "network" {
  source = "./modules/network"

  name                 = var.project_name
  vpc_cidr             = var.vpc_cidr
  availability_zones   = local.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}
