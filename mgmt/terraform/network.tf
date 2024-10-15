### VPC: MGMT
module "vpc" {
  source = "./modules/network/vpc"

  name = local.basename
  cidr = local.vpc_cidr
  ipv6 = var.vpc_ipv6_cidr

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
  prefix = local.vpc_cidr
  base   = 0

  ipv6        = var.vpc_ipv6_cidr
  ipv6_prefix = module.vpc.vpc.ipv6_cidr

  tags = merge(local.base_tags, {
    Tier = "Public"
  })
}

# VPC Subnets: Private
module "private-subnets" {
  source = "./modules/network/subnets/"

  name = local.basename
  type = "Private"

  vpc_id = module.vpc.vpc.id

  one_nat = true

  nat_subnets = module.public-subnets.subnets.ids

  zones  = local.zone_names
  prefix = local.vpc_cidr
  base   = 3

  ipv6        = var.vpc_ipv6_cidr
  ipv6_prefix = module.vpc.vpc.ipv6_cidr

  tags = merge(local.base_tags, {
    Tier = "Private"
  })
}

### Outputs
output "vpc" {
  value = {
    id        = module.vpc.vpc.id
    name      = module.vpc.vpc.name
    ipv4_cidr = module.vpc.vpc.ipv4_cidr
    ipv6_cidr = module.vpc.vpc.ipv6_cidr

    rt_default = module.vpc.route_table
    rt_public  = module.public-subnets.route_table
    rt_private = module.private-subnets.route_table
  }
}
