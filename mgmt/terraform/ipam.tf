# resource "aws_vpc_ipam" "main" {
#   description = local.basename
#   operating_regions {
#     region_name = data.aws_region.current.name
#   }
# }

# resource "aws_vpc_ipam_pool" "base" {
#   address_family = "ipv4"
#   ipam_scope_id  = aws_vpc_ipam.main.private_default_scope_id
#   locale         = data.aws_region.current.name
# }

# resource "aws_vpc_ipam_pool_cidr" "parent_test" {
#   ipam_pool_id = aws_vpc_ipam_pool.base.id
#   cidr         = "172.20.0.0/16"
# }


module "ipam" {
  source = "aws-ia/ipam/aws"
  # See https://github.com/aws-ia/terraform-aws-ipam/blob/main/examples/single_scope_ipv4/main.tf

  top_cidr = ["10.192.0.0/10"]
  top_name = local.basename

  pool_configurations = {
    eu-west-2 = {
      description = "eu-west-2 pool"
      cidr        = ["10.192.0.0/11"]

      sub_pools = {
        management = {
          netmask_length       = 13
          name                 = "management"
          ram_share_principals = ["390403900367"]
          sub_pools = {
            mgmt = {
              name           = "mgmt"
              description    = "Management network"
              netmask_length = 14
            }
          }
        }

        sandbox = {
          name                 = "Sandbox"
          netmask_length       = 13
          ram_share_principals = ["arn:aws:organizations::444629336067:ou/o-mmrpss74fy/ou-2ure-5cusy3i7"]
          allocation_resource_tags = {
            env = "Sandbox"
          }
          sub_pools = {
            eks_public_module = {
              name           = "EKS public module"
              netmask_length = 15
            }

            sandbox-aft-test-request-2 = {
              name           = "sandbox-aft-test-request-2"
              netmask_length = 15
            }
          }
        }

        dev = {
          name           = "Dev"
          netmask_length = 14
          sub_pools = {
            team_a = {
              name           = "Team A"
              netmask_length = 15
            }

            team_b = {
              name           = "Team B"
              netmask_length = 15
            }
          }
        }
        prod = {
          name           = "Prod"
          netmask_length = 14
          sub_pools = {
            team_a = {
              name           = "Team A"
              netmask_length = 15
            }
            team_b = {
              name           = "Team B"
              netmask_length = 15
            }
          }
        }
      }
    }
  }
}
