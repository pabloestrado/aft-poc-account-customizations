### VPC
resource "aws_vpc" "vpc" {
  cidr_block          = var.cidr
  ipv4_ipam_pool_id   = var.ipam_pool_id
  ipv4_netmask_length = var.netmask_length
  ipv6_ipam_pool_id   = var.ipv6_ipam_pool_id
  ipv6_netmask_length = var.ipv6_netmask_length

  assign_generated_ipv6_cidr_block = var.ipv6_ipam_pool_id != null ? null : var.ipv6

  enable_dns_hostnames = true

  tags = merge(var.tags, var.vpc_tags, {
    Name = "${var.name}-VPC"
  })
}

# Default Route Table
resource "aws_default_route_table" "vpc" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id

  tags = merge(var.tags, {
    Name = "${var.name}-Default-RT"
  })
}

# Default Security Group
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.vpc.id
}

### Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(var.tags, {
    Name = "${var.name}-Public-IGW"
    Tier = "Public"
  })
}
