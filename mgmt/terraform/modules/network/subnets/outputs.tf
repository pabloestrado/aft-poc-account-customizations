### Outputs
output "subnets" {
  description = "Subnet attributes"
  value = {
    # List of subnet ID
    ids = aws_subnet.subnets[*].id
    # Map of subnet = az
    azs = { for s in aws_subnet.subnets : s.availability_zone => s.id }
  }
}
output "route_table" {
  description = "Route table attributes"
  value = {
    # Route table ID
    id = aws_route_table.table[*].id
  }
}
output "eigw" {
  description = "Internet Gateway attributes"
  value = {
    # Egress Only Internet Gateway ID
    id = aws_egress_only_internet_gateway.ipv6-egress-igw[*].id
  }
}
