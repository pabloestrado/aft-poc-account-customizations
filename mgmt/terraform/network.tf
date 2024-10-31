# ### VPC: MGMT


# module "mgmt_vpc" {
#   source  = "terraform-aws-modules/vpc/aws"
#   version = "~> 5.14"
#   name    = local.basename

#   use_ipam_pool     = true
#   ipv4_ipam_pool_id = aws_vpc_ipam_pool.mgmt.id
#   #cidr              = aws_vpc_ipam_preview_next_cidr.preview_cidr.cidr

#   azs = ["${local.region}a", "${local.region}b", "${local.region}c"]

#   enable_nat_gateway = false
#   single_nat_gateway = true
# }

module "mgmt-vpc" {
  source = "./modules/network/vpc"

  name           = local.basename
  ipam_pool_id   = aws_vpc_ipam_pool.mgmt.id
  netmask_length = 16
  ipv6           = true

  tags = local.base_tags
}


# VPC Subnets: Public
module "mgmt-public-subnets" {
  source = "./modules/network/subnets/"

  name = local.basename
  type = "Public"

  vpc_id = module.mgmt-vpc.vpc.id
  igw_id = module.mgmt-vpc.igw.id

  zones  = local.zone_names
  prefix = module.mgmt-vpc.vpc.ipv4_cidr
  base   = 0

  ipv6        = true
  ipv6_prefix = module.mgmt-vpc.vpc.ipv6_cidr
  tags = merge(local.base_tags, {
    Tier                     = "Public"
    "kubernetes.io/role/elb" = "1"
  })
}

# VPC Subnets: Private
module "mgmt-private-subnets" {
  source = "./modules/network/subnets/"

  name = local.basename
  type = "Private"

  vpc_id = module.mgmt-vpc.vpc.id

  one_nat = false

  nat_subnets = module.mgmt-public-subnets.subnets.ids

  zones  = local.zone_names
  prefix = module.mgmt-vpc.vpc.ipv4_cidr
  base   = 3

  ipv6        = true
  ipv6_prefix = module.mgmt-vpc.vpc.ipv6_cidr

  tags = merge(local.base_tags, {
    Tier                              = "Private"
    "kubernetes.io/role/internal-elb" = "1"
  })
}


module "vpc" {
  source = "./modules/network/vpc"

  name           = local.basename
  ipam_pool_id   = aws_vpc_ipam_pool.mgmt.id
  netmask_length = 16
  ipv6           = false

  tags = local.base_tags
}

# VPC Subnets: Public
module "public-subnets" {
  source = "./modules/network/subnets/"

  name = local.basename
  type = "Public"

  vpc_id = module.vpc.vpc.id
  igw_id = module.vpc.igw.id

  zones  = local.zone_names
  prefix = module.vpc.vpc.ipv4_cidr
  base   = 0

  ipv6        = false
  ipv6_prefix = module.vpc.vpc.ipv6_cidr
  tags = merge(local.base_tags, {
    Tier                     = "Public"
    "kubernetes.io/role/elb" = "1"
  })
}

