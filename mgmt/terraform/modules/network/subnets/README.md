<!-- BEGIN_TF_DOCS -->
# MODULE: Subnets for each AZ

## General

This module creates a subnet in each availability zone, adding the required tags and optionally associating the subnet with a particular route table.

No specific role (public, private, or isolated) is imposed on subnets, users should take care of this.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Base name for the subnets. \"-SUBNET-x\" is appended to this value, where \"x\" is the last character of corresponding availability zone name | `string` | n/a | yes |
| prefix | IPv4 prefix for the first subnet
See
    Terraform `cidrsubnet()` function documentation for details. | `string` | n/a | yes |
| bits | IP bit width for the first subnet | `number` | 8 | no |
| base | IP base number for the first subnet | `number` | 0 | no |
| igw_id | Internet Gageway ID | `string` | null | no |
| ipv6_prefix | IP prefix with VPC IPv6 CIDR block | `string` | n/a | yes |
| ipv6 | A flag shows if IPv6 is used in that environment | `bool` | true | no |
| nat_subnets | Public subnets for NAT Gateway | `list(string)` | null | no |
| one_nat | Multiple NAT Gateway | `bool` | false | no |
| prefix | IP prefix with VPC IPv4 CIDR block | `string` | n/a | yes |
| route_table | Route table to associate subnets with | `list(string)` | null | no |
| type | Subnet type: Public, Private or Isolated | `string` | n/a | yes |
| vpc_id | VPC in which to place the subnets | `string` | n/a | yes |
| zones | Availability zone names to cover with subnets | `list(string)` | n/a | yes |
| tags | Extra tags for all the resources | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| ids | A list of subnet IDs, in the same order the `zones` are specified |
| azs | A map with zone name as key and corresponding subnet ID, for convenient access |

## Example

Used in `vpc/3tier` module as follows:

```terraform
    ### Subnets: Public subnets
    module "public-subnets" {
      source = "../subnets/"

      vpc_id   = module.vpc.id
      basename = "${var.name}-Public"

      zones  = var.public_zones
      prefix = var.cidr
      bits   = var.public_bits
      base   = var.public_base

      route_table = aws_route_table.public.id

      tags = merge(var.tags, var.public_tags, {
        Tier = "Public"
      })
    }
```

More examples can be found in `vpc/3tier` module README.

---
Copyright (c) 2023 Automat-IT
<!-- END_TF_DOCS -->