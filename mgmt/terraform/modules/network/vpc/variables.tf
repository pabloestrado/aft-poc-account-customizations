### Variables
variable "cidr" {
  type        = string
  description = "The IPv4 CIDR block for the VPC"
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
