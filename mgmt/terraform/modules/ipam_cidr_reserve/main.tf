data "aws_vpc_ipam_preview_next_cidr" "this" {
  ipam_pool_id = var.ipam_pool_id
}

output "cidr" {
  value = data.aws_vpc_ipam_preview_next_cidr.this.cidr
}

output "private_subnets" {
  value = slice(
    cidrsubnets(data.aws_vpc_ipam_preview_next_cidr.this.cidr, 3, 3, 3, 3, 3, 3, 3, 3),
  0, 3)
}

output "public_subnets" {
  value = slice(
    cidrsubnets(data.aws_vpc_ipam_preview_next_cidr.this.cidr, 3, 3, 3, 3, 3, 3, 3, 3),
  4, 7)
}
