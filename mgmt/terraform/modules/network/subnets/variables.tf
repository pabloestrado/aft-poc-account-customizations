### Variables
variable "name" {
  type        = string
  description = "Basename for resources"
}
variable "vpc_id" {
  type        = string
  description = "VPC ID"
}
variable "igw_id" {
  type        = string
  default     = null
  description = "Internet Gateway ID"
}
variable "type" {
  type        = string
  description = "Subnet type: Public, Private or Isolated"

  validation {
    condition     = contains(["Public", "Private", "Isolated"], var.type)
    error_message = "Valid values for var: Public, Private or Isolated."
  }
}
variable "one_nat" {
  type        = bool
  default     = false
  description = "Multiple NAT Gateway"
}
variable "nat_subnets" {
  type        = list(string)
  default     = null
  description = "Public subnets for NAT gateway"
}
variable "route_table" {
  type        = list(string)
  default     = null
  description = "Default route table"
}
variable "zones" {
  type        = list(string)
  description = "List of availability zones"
}
variable "prefix" {
  type        = string
  description = "VPC IPv4 CIDR"
}
variable "bits" {
  type        = number
  default     = 4
  description = "Additional bits with which to extend the prefix"
}
variable "base" {
  type        = number
  default     = 0
  description = "To populate the additional bits added to the prefix"
}
variable "ipv6_prefix" {
  type        = string
  description = "VPC IPv6 CIDR"
}
variable "ipv6" {
  type        = bool
  default     = true
  description = "Usage of IPv6 CIDR"
}
variable "tags" {
  type        = map(string)
  default     = {}
  description = "Map of tags"
}
