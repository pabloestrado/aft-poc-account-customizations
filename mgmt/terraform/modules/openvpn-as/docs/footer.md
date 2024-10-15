# Usage

```terraform
# Choose random subnet of all the available public
resource "random_shuffle" "openvpn-subnet" {
  input = module.vpc.public_subnets.ids

  result_count = 1
}

# OpenVPN instance
module "openvpn" {
  source = "../../modules/openvpn-as/"

  name = "${local.basename}-OpenVPN"
  tags = local.base_tags

  vpc_id    = module.vpc.id
  subnet_id = random_shuffle.openvpn-subnet.result[0]

  # Access from office
  vpn_access_cidrs = ["31.128.73.0/24"]
}

### Outputs
output openvpn {
  value = {
    public_ip  = module.openvpn.public_ip
    admin_user = module.openvpn.admin_user
    admin_pass = module.openvpn.admin_pass
  }
}
```