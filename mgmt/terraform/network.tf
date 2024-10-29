# ### VPC: MGMT


# module "vpc" {
#   source = "terraform-aws-modules/vpc/aws"

#   name = local.basename

#   use_ipam_pool     = true
#   ipv4_ipam_pool_id = aws_vpc_ipam_pool.prod.id
#   cidr              = aws_vpc_ipam_preview_next_cidr.preview_cidr.cidr

#   azs             = ["${local.region}a", "${local.region}b", "${local.region}c"]
#   private_subnets = local.vpc_private_subnets
#   public_subnets  = local.vpc_public_subnets

#   enable_nat_gateway = false
#   single_nat_gateway = true
# }

# resource "aws_vpc_ipam_preview_next_cidr" "preview_cidr" {
#   ipam_pool_id = aws_vpc_ipam_pool.prod.id
# }

# locals {
#   ipam_cidr = aws_vpc_ipam_preview_next_cidr.preview_cidr.cidr

#   vpc_public_cidr  = cidrsubnet(local.ipam_cidr, 1, 0) # Half of VPC range
#   vpc_private_cidr = cidrsubnet(local.ipam_cidr, 1, 1) # Rest of VPC range

#   vpc_public_subnets  = cidrsubnets(local.vpc_public_cidr, 2, 2, 2)
#   vpc_private_subnets = cidrsubnets(local.vpc_private_cidr, 2, 2, 2)
# }
