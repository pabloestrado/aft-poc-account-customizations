### Outputs
output "vpc" {
  description = "VPC attributes"
  value = {
    # VPC ID
    id = aws_vpc.vpc.id
    # VPC Basename
    name = var.name
    # VPC IPv4 CIDR
    ipv4_cidr = aws_vpc.vpc.cidr_block
    # VPC IPv6 CIDR
    ipv6_cidr = aws_vpc.vpc.ipv6_cidr_block
  }
}
output "route_table" {
  description = "Default route table attributes"
  value = {
    # Route Table ID
    id = aws_vpc.vpc.default_route_table_id
  }
}
output "igw" {
  description = "Internet Gateway attributes"
  value = {
    # Internet Gateway ID
    id = aws_internet_gateway.igw.id
  }
}
