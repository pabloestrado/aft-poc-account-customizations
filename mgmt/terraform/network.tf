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

  name           = "mgmt"
  ipam_pool_id   = aws_vpc_ipam_pool.mgmt.id
  netmask_length = 16
  ipv6           = true

  tags = local.base_tags
}


# VPC Subnets: Public
module "mgmt-public-subnets" {
  source = "./modules/network/subnets/"

  name = "mgmt-public"
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

  name = "mgmt-private"
  type = "Isolated"

  vpc_id = module.mgmt-vpc.vpc.id

  zones  = local.zone_names
  prefix = module.mgmt-vpc.vpc.ipv4_cidr
  base   = 3

  route_table = [aws_route_table.mgmt-isolated.id]

  ipv6        = true
  ipv6_prefix = module.mgmt-vpc.vpc.ipv6_cidr

  tags = merge(local.base_tags, {
    Tier                              = "Private"
    "kubernetes.io/role/internal-elb" = "1"
  })
}


# resource "aws_route" "mgmt-default" {
#   route_table_id         = module.mgmt-private-subnets.route_table.id.0
#   transit_gateway_id     = module.tgw.ec2_transit_gateway_id
#   destination_cidr_block = "0.0.0.0/0"
# }

resource "aws_ec2_transit_gateway_vpc_attachment" "mgmt" {
  subnet_ids         = module.mgmt-private-subnets.subnets.ids
  transit_gateway_id = module.tgw.ec2_transit_gateway_id
  vpc_id             = module.mgmt-vpc.vpc.id
  tags = merge(local.base_tags, {
    Name = "mgmt"
  })
}

resource "aws_ec2_transit_gateway_route_table_association" "mgmt" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.mgmt.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.inspection.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "mgmt" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.mgmt.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.firewall.id
}

resource "aws_route_table" "mgmt-isolated" {
  vpc_id = module.mgmt-vpc.vpc.id

  route {
    cidr_block         = "0.0.0.0/0"
    transit_gateway_id = module.tgw.ec2_transit_gateway_id
  }

  tags = merge(
    local.base_tags,
    {
      Name = "mgmt-isolated-rtb"
    }
  )
}
