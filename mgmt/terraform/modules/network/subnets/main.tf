### Subnets: One per AZ
resource "aws_subnet" "subnets" {
  count = length(var.zones)

  vpc_id          = var.vpc_id
  cidr_block      = cidrsubnet(var.prefix, var.bits, var.base + count.index)
  ipv6_cidr_block = var.ipv6 ? cidrsubnet(var.ipv6_prefix, var.bits, var.base + count.index) : null

  availability_zone = var.zones[count.index]

  tags = merge(var.tags, {
    Name = "${var.name}-${var.type}-Subnet-${substr(var.zones[count.index], -1, 1)}"
  })
}

### Route Table
resource "aws_route_table" "table" {
  count = var.type == "Public" ? 1 : (var.type == "Private" ? (var.one_nat ? 1 : length(var.zones)) : 0)

  vpc_id = var.vpc_id
  tags = merge(var.tags, {
    Name = "${var.name}-${var.type}-RT"
    Tier = var.type
  })
}

# Route: Default Public IPv4 routing via IGW
resource "aws_route" "igw" {
  count = var.type == "Public" ? 1 : 0

  route_table_id         = aws_route_table.table[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = var.igw_id
}

# Route: Default Public IPv6 routing via IGW
resource "aws_route" "igw-ipv6" {
  count = var.type == "Public" && var.ipv6 ? 1 : 0

  route_table_id              = aws_route_table.table[0].id
  destination_ipv6_cidr_block = "::/0"
  gateway_id                  = var.igw_id
}

# Route Table Attachments
resource "aws_route_table_association" "rt-assoc" {
  count = var.type == "Public" || var.type == "Private" ? length(var.zones) : 0

  subnet_id      = aws_subnet.subnets[count.index].id
  route_table_id = element(aws_route_table.table[*].id, count.index)
}

### Elastic IP
resource "aws_eip" "natgw" {
  count = var.type == "Private" ? (var.one_nat ? 1 : length(var.zones)) : 0

  domain = "vpc"

  tags = merge(var.tags, {
    Name = "${var.name}-NATGW-EIP-${count.index}"
    Tier = var.type
  })
}

### NAT Gateway
resource "aws_nat_gateway" "natgw" {
  count = var.type == "Private" ? (var.one_nat ? 1 : length(var.zones)) : 0

  subnet_id     = var.nat_subnets[count.index]
  allocation_id = aws_eip.natgw[count.index].id

  tags = merge(var.tags, {
    Name = "${var.name}-${var.type}-NATGW-${count.index}"
    Tier = var.type
  })
}

# Route via NAT GW
resource "aws_route" "private-natgw" {
  count = var.type == "Private" ? (var.one_nat ? 1 : length(var.zones)) : 0

  route_table_id         = aws_route_table.table[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.natgw[count.index].id
}

### Route Table Attachments: Isolated
resource "aws_route_table_association" "rt-assoc-isolated" {
  count = var.type == "Isolated" ? length(var.zones) : 0

  subnet_id      = aws_subnet.subnets[count.index].id
  route_table_id = element(var.route_table, count.index)
}

### IPv6 Egress-only Internet Gateway
resource "aws_egress_only_internet_gateway" "ipv6-egress-igw" {
  count  = var.type == "Private" && var.ipv6 ? 1 : 0
  vpc_id = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.name}-${var.type}-VPC-IPv6-Egress-Only-IGW"
    Tier = var.type
  })
}

# Route for Private Subnets to access the Egress-Only Internet Gateway
resource "aws_route" "private-ipv6-egress-igw" {
  count                       = var.type == "Private" && var.ipv6 ? 1 : 0
  route_table_id              = aws_route_table.table[count.index].id
  destination_ipv6_cidr_block = "::/0"
  egress_only_gateway_id      = aws_egress_only_internet_gateway.ipv6-egress-igw[count.index].id
}
