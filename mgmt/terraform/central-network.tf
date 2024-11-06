# egress VPC
module "egress-vpc" {
  source = "./modules/network/vpc"

  name           = "egress"
  ipam_pool_id   = aws_vpc_ipam_pool.mgmt.id
  netmask_length = 16
  ipv6           = false

  tags = local.base_tags
}

# VPC Subnets: Public
module "egress-public-subnets" {
  source = "./modules/network/subnets/"

  name = "egress"
  type = "Public"

  vpc_id = module.egress-vpc.vpc.id
  igw_id = module.egress-vpc.igw.id

  zones  = local.zone_names
  prefix = module.egress-vpc.vpc.ipv4_cidr
  base   = 0

  ipv6        = false
  ipv6_prefix = module.egress-vpc.vpc.ipv6_cidr
  tags = merge(local.base_tags, {
    Tier                     = "Public"
    "kubernetes.io/role/elb" = "1"
  })
}

# VPC Subnets: Private
module "egress-private-subnets" {
  source = "./modules/network/subnets/"

  name = "egress"
  type = "Private"

  vpc_id = module.egress-vpc.vpc.id

  one_nat = false

  nat_subnets = module.egress-public-subnets.subnets.ids

  zones  = local.zone_names
  prefix = module.egress-vpc.vpc.ipv4_cidr
  base   = 3

  ipv6        = false
  ipv6_prefix = module.egress-vpc.vpc.ipv6_cidr

  tags = merge(local.base_tags, {
    Tier                              = "Private"
    "kubernetes.io/role/internal-elb" = "1"
  })
}

resource "aws_route" "egress-public" {
  for_each               = zipmap(range(length(module.egress-public-subnets.route_table.id)), module.egress-public-subnets.route_table.id)
  route_table_id         = each.value
  destination_cidr_block = "10.0.0.0/8"
  transit_gateway_id     = module.tgw.ec2_transit_gateway_id

  depends_on = [module.egress-public-subnets]
}

resource "aws_route" "egress-private" {
  for_each               = zipmap(range(length(module.egress-private-subnets.route_table.id)), module.egress-private-subnets.route_table.id)
  route_table_id         = each.value
  destination_cidr_block = "10.0.0.0/8"
  transit_gateway_id     = module.tgw.ec2_transit_gateway_id

  depends_on = [module.egress-private-subnets]
}

# Inspection VPC
module "inspection-vpc" {
  source = "./modules/network/vpc"

  name           = "inspection"
  ipam_pool_id   = aws_vpc_ipam_pool.cgnat.id
  netmask_length = 16
  ipv6           = false

  tags = local.base_tags
}

# VPC Subnets: Transit Gateway
module "inspection-tgw-subnets" {
  source = "./modules/network/subnets/"

  name = "inspection-tgw"
  type = "Isolated"

  vpc_id = module.inspection-vpc.vpc.id

  zones  = [local.zone_names.0]
  prefix = module.inspection-vpc.vpc.ipv4_cidr
  base   = 0

  ipv6        = false
  ipv6_prefix = module.inspection-vpc.vpc.ipv6_cidr

  route_table = [aws_route_table.inspection-tgw.id]
}

# VPC Subnets: Firewall
module "inspection-firewall-subnets" {
  source = "./modules/network/subnets/"

  name = "inspection-firewall"
  type = "Isolated"

  vpc_id = module.inspection-vpc.vpc.id

  zones  = [local.zone_names.0]
  prefix = module.inspection-vpc.vpc.ipv4_cidr
  base   = 3

  ipv6        = false
  ipv6_prefix = module.inspection-vpc.vpc.ipv6_cidr
  route_table = [aws_route_table.inspection-tgw.id]
}


resource "aws_ec2_transit_gateway_vpc_attachment" "inspection" {
  subnet_ids         = module.inspection-tgw-subnets.subnets.ids
  transit_gateway_id = module.tgw.ec2_transit_gateway_id
  vpc_id             = module.inspection-vpc.vpc.id
  tags = merge(local.base_tags, {
    Name = "inspection"
  })
}

resource "aws_route_table" "inspection-tgw" {
  vpc_id = module.inspection-vpc.vpc.id

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

# resource "aws_route_table" "egress-private" {
#   vpc_id = module.inspection-vpc.vpc.id

#   route {
#     cidr_block         = "0.0.0.0/0"
#     transit_gateway_id = module.tgw.ec2_transit_gateway_id
#   }

#   tags = merge(
#     local.base_tags,
#     {
#       Name = "mgmt-isolated-rtb"
#     }
#   )
# }

module "tgw" {
  source  = "terraform-aws-modules/transit-gateway/aws"
  version = "~> 2.0"

  name        = "${local.basename}-tgw"
  description = "Transit gateway for centralized network access"

  enable_auto_accept_shared_attachments = true

  create_tgw_routes                      = false
  enable_default_route_table_association = false
  enable_default_route_table_propagation = false
}

resource "aws_ec2_transit_gateway_vpc_attachment" "egress" {
  subnet_ids         = module.egress-private-subnets.subnets.ids
  transit_gateway_id = module.tgw.ec2_transit_gateway_id
  vpc_id             = module.egress-vpc.vpc.id
  tags = merge(local.base_tags, {
    Name = "inspection"
  })
}

### Inspection route table
resource "aws_ec2_transit_gateway_route_table" "inspection" {
  transit_gateway_id = module.tgw.ec2_transit_gateway_id
  tags = merge({
    Name = "Inspection"
    },
  local.base_tags)
}

resource "aws_ec2_transit_gateway_route" "inspection_catchall_route" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.inspection.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.inspection.id
}
###

### Firewall routing table
resource "aws_ec2_transit_gateway_route_table" "firewall" {
  transit_gateway_id = module.tgw.ec2_transit_gateway_id
  tags = merge({
    Name = "Firewall"
    },
  local.base_tags)
}

resource "aws_ec2_transit_gateway_route" "firewall_catchall_route" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.egress.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.firewall.id
}

resource "aws_ec2_transit_gateway_route_table_association" "inspection" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.inspection.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.firewall.id
}

# resource "aws_ec2_transit_gateway_route_table_propagation" "inspection" {
#   transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.mgmt.id
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.firewall.id
# }


resource "aws_ec2_transit_gateway_route_table_association" "egress" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.egress.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.firewall.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "egress" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.egress.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.firewall.id
}
###


### Egress routing table


###
