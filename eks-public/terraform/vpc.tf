module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = local.basename
  cidr = local.vpc_cidr

  azs             = ["${local.region}a", "${local.region}b", "${local.region}c"]
  private_subnets = local.vpc_private_subnets
  public_subnets  = local.vpc_public_subnets

  enable_nat_gateway = true
  single_nat_gateway = true
}

locals {
  vpc_public_cidr  = cidrsubnet(local.vpc_cidr, 1, 0) # Half of VPC range
  vpc_private_cidr = cidrsubnet(local.vpc_cidr, 1, 1) # Rest of VPC range

  vpc_public_subnets  = cidrsubnets(local.vpc_public_cidr, 2, 2, 2)
  vpc_private_subnets = cidrsubnets(local.vpc_private_cidr, 2, 2, 2)
}

