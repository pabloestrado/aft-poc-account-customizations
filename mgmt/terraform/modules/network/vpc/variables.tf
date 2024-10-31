### Variables
variable "cidr" {
  type        = string
  description = "The IPv4 CIDR block for the VPC"
  default     = null
}
variable "ipv6" {
  type        = bool
  default     = true
  description = "Add IPv6 CIDR block to the VPC"
}
variable "name" {
  type        = string
  description = "Basename for resources"
}
variable "tags" {
  type        = map(string)
  default     = {}
  description = "A map of tags to assign to the resource"
}
variable "vpc_tags" {
  type        = map(string)
  default     = {}
  description = "A map of tags to assign to the VPC only"
}
variable "ipam_pool_id" {
  type        = string
  default     = null
  description = "IPAM pool ID for CIDR allocation"
}
variable "ipv6_ipam_pool_id" {
  type        = string
  default     = null
  description = "IPAM pool ID for IPv6 CIDR allocation"
}
variable "netmask_length" {
  type        = number
  default     = null
  description = "IPAM netmask length for CIDR allocation"

  validation {
    condition     = var.netmask_length == null ? true : (var.netmask_length >= 16 && var.netmask_length <= 28)
    error_message = "The allowed block size is between a /16 netmask (65,536 IP addresses) and /28 netmask (16 IP addresses). See https://docs.aws.amazon.com/vpc/latest/userguide/vpc-cidr-blocks.html#vpc-sizing-ipv4"
  }
}
variable "ipv6_netmask_length" {
  type        = number
  default     = null
  description = "IPAM netmask length for IPv6 CIDR allocation"
  validation {
    condition     = var.ipv6_netmask_length == null ? true : (var.ipv6_netmask_length >= 44 && var.ipv6_netmask_length <= 60 && (var.ipv6_netmask_length % 4 == 0))
    error_message = "IPv6 allowed block size is between a /44 to /60 in increments of /4. See https://docs.aws.amazon.com/vpc/latest/userguide/vpc-cidr-blocks.html#vpc-sizing-ipv6"
  }
}
