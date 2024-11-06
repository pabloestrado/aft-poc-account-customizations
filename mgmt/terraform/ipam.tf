resource "aws_vpc_ipam" "ipam" {
  description = local.basename
  operating_regions {
    region_name = data.aws_region.current.name
  }
}

# Parrent base pool
resource "aws_vpc_ipam_pool" "base" {
  description    = local.basename
  address_family = "ipv4"
  ipam_scope_id  = aws_vpc_ipam.ipam.private_default_scope_id
  locale         = data.aws_region.current.name

  tags = merge(local.base_tags, {
    Name = local.basename
  })
}

resource "aws_vpc_ipam_pool_cidr" "base" {
  ipam_pool_id = aws_vpc_ipam_pool.base.id
  cidr         = "10.192.0.0/10"
}

# Management pool
resource "aws_vpc_ipam_pool" "mgmt" {
  description                       = "Management"
  address_family                    = "ipv4"
  ipam_scope_id                     = aws_vpc_ipam.ipam.private_default_scope_id
  locale                            = data.aws_region.current.name
  source_ipam_pool_id               = aws_vpc_ipam_pool.base.id
  allocation_default_netmask_length = 16

  tags = merge(local.base_tags, {
    Name = "mgmt"
  })
}

resource "aws_vpc_ipam_pool_cidr" "mgmt" {
  ipam_pool_id   = aws_vpc_ipam_pool.mgmt.id
  netmask_length = 12
}

# Production pool
resource "aws_vpc_ipam_pool" "prod" {
  description                       = "Production"
  address_family                    = "ipv4"
  ipam_scope_id                     = aws_vpc_ipam.ipam.private_default_scope_id
  locale                            = data.aws_region.current.name
  source_ipam_pool_id               = aws_vpc_ipam_pool.base.id
  allocation_default_netmask_length = 16

  tags = merge(local.base_tags, {
    Name = "prod"
  })
}

resource "aws_vpc_ipam_pool_cidr" "prod" {
  ipam_pool_id   = aws_vpc_ipam_pool.prod.id
  netmask_length = 12
}


# Development pool
resource "aws_vpc_ipam_pool" "dev" {
  description                       = "Development"
  address_family                    = "ipv4"
  ipam_scope_id                     = aws_vpc_ipam.ipam.private_default_scope_id
  locale                            = data.aws_region.current.name
  source_ipam_pool_id               = aws_vpc_ipam_pool.base.id
  allocation_default_netmask_length = 16

  tags = merge(local.base_tags, {
    Name = "dev"
  })
}

resource "aws_vpc_ipam_pool_cidr" "dev" {
  ipam_pool_id   = aws_vpc_ipam_pool.dev.id
  netmask_length = 12
}

# Share dev pool with sandbox OU
resource "aws_ram_resource_share" "ipam_pool_dev" {
  name                      = "ipam-pool-dev"
  allow_external_principals = false
}

resource "aws_ram_resource_association" "ipam_pool_dev" {
  resource_arn       = aws_vpc_ipam_pool.dev.arn
  resource_share_arn = aws_ram_resource_share.ipam_pool_dev.arn
}

resource "aws_ram_principal_association" "ipam_pool_dev" {
  principal          = "arn:aws:organizations::444629336067:ou/o-mmrpss74fy/ou-2ure-5cusy3i7"
  resource_share_arn = aws_ram_resource_share.ipam_pool_dev.arn
}


# Parrent base pool
resource "aws_vpc_ipam_pool" "cgnat" {
  description    = "CGNAT"
  address_family = "ipv4"
  ipam_scope_id  = aws_vpc_ipam.ipam.private_default_scope_id
  locale         = data.aws_region.current.name

  tags = merge(local.base_tags, {
    Name = "CGNAT"
  })
}

resource "aws_vpc_ipam_pool_cidr" "cgnat" {
  ipam_pool_id = aws_vpc_ipam_pool.cgnat.id
  cidr         = "100.64.0.0/10"
}
