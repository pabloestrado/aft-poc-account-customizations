### VPC: MGMT


module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = local.basename

  use_ipam_pool       = true
  ipv4_ipam_pool_id   = data.aws_vpc_ipam_pool.pool.id
  ipv4_netmask_length = local.vpc_netmask_length
  cidr                = local.ipam_cidr

  azs             = ["${local.region}a", "${local.region}b", "${local.region}c"]
  private_subnets = local.vpc_private_subnets
  public_subnets  = local.vpc_public_subnets

  enable_nat_gateway = true
  single_nat_gateway = true
}

data "aws_vpc_ipam_pool" "pool" {
  filter {
    name   = "tag:env"
    values = ["management"]
  }

  filter {
    name   = "ipam-scope-id"
    values = [module.ipam.ipam_info.private_default_scope_id]
  }

  filter {
    name   = "address-family"
    values = ["ipv4"]
  }
}

resource "aws_vpc_ipam_preview_next_cidr" "preview_cidr" {
  ipam_pool_id   = data.aws_vpc_ipam_pool.pool.id
  netmask_length = local.vpc_netmask_length

  depends_on = [
    module.ipam
  ]
}

locals {
  vpc_netmask_length = 18
  ipam_cidr          = aws_vpc_ipam_preview_next_cidr.preview_cidr.cidr

  vpc_public_cidr  = cidrsubnet(local.ipam_cidr, 1, 0) # Half of VPC range
  vpc_private_cidr = cidrsubnet(local.ipam_cidr, 1, 1) # Rest of VPC range

  vpc_public_subnets  = cidrsubnets(local.vpc_public_cidr, 2, 2, 2)
  vpc_private_subnets = cidrsubnets(local.vpc_private_cidr, 2, 2, 2)
}
