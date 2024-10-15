variable "install_openvpnas" { type = bool }
variable "vpn_create_ssl" { type = bool }
variable "ovpn_download" { type = bool }
variable "ovpn_product_code" { type = string }
variable "vpc_ipv6_cidr" { type = bool }

variable "total_azs" {
  type    = number
  default = 3
}
