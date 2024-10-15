### Variables
variable "name_prefix" {
  description = "Name prefix for the resources"
  type        = string
}
variable "tags" {
  description = "Map of tags to apply to the resources"
  type        = map(string)
  default     = {}
}
variable "vpc_id" {
  description = "VPC ID where to run OpenVPN server"
  type        = string
}
variable "subnet_id" {
  description = "Subnet ID where to run OpenVPN server"
  type        = string
}
variable "ssh_access_cidrs" {
  description = "List of CIDRs to allow SSH port access. Set empty list to disable SSH access"
  type        = list(string)
  default     = []
}
variable "ssh_key" {
  description = "If set, launch OpenVPN server with specified Key Pair"
  type        = string
  default     = null
}
variable "instance_type" {
  description = "OpenVPN instance type"
  type        = string
  default     = "t3.small"
}
variable "root_ebs_size" {
  description = "OpenVPN server volume size"
  type        = number
  default     = 10
}
variable "admin_user" {
  description = "OpenVPN admin user name"
  type        = string
  default     = "openvpn"
}
variable "admin_port" {
  description = "OpenVPN admin UI port"
  type        = number
  default     = 443
}
variable "vpn_access_cidrs" {
  description = "List of CIDRs to allow inbound connection to OpenVPN server"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
variable "project_domain" {
  description = "Domain zone to create DNS record for OpenVPN"
  type        = string
  default     = ""
}
variable "configure_vpn" {
  description = "Whether to apply custom configuration on the default OpenVPN AMI"
  type        = bool
  default     = true
}
variable "ovpn_download" {
  description = "Whether to download admin user OpenVPN client auto-login profile"
  type        = bool
  default     = false
}
variable "vpn_routes_cidrs" {
  description = "List of private subnets to route traffic to over OpenVPN. NAT mode is used by default"
  type        = list(string)
  default     = []
}
variable "kms_key_id" {
  description = "If present, will be used to encrypt OpenVPN server volume"
  type        = string
  default     = null
}
variable "product_code" {
  description = "OpenVPN server product code on AWS Marketplace. Check README for available values"
  type        = string
  default     = "f2ew2wrz425a1jagnifd02u5t"
}
variable "owner_id" {
  description = "OpenVPN server owner id on AWS Marketplace. Check README for available values"
  type        = string
  default     = "679593333241"
}
variable "vpn_create_ssl" {
  description = "Whether to create SSL cert and DNS for OpenVPN server. Requires `project_domain` if set to `true`"
  type        = bool
  default     = false
}
variable "encrypt_ebs" {
  description = "If present and kms_key_id == null, will create kms key and used to encrypt OpenVpn root volume. If kms_key_id != null, will use key form value"
  type        = bool
  default     = true
}
variable "kms_rotation" {
  description = "If present, will rotate created kms key in this module"
  type        = bool
  default     = true
}
variable "allow_ssh" {
  description = "If present, will push ssh key to the instance"
  type        = bool
  default     = false
}
variable "enable_detailed_monitoring" {
  description = "If true, the launched EC2 instance will have detailed monitoring"
  type        = bool
  default     = false
}
variable "ebs_optimized" {
  description = "If true, the launched EC2 instance will be EBS-optimized"
  type        = bool
  default     = true
}
variable "session_logs_bucket_arn" {
  description = "Logging bucket arn for IAM policy"
  type        = string
  default     = ""
}
variable "ssmkey_arn" {
  description = "Logging KMS key arn for IAM policy"
  type        = string
  default     = ""
}
variable "enable_ssh_logging" {
  description = "If present, will push ssm ssh access logs to Cloudwatch/S3"
  type        = bool
  default     = false
}
variable "openvpn_userlist_apigw_url" {
  description = "API Gateway URL for sending POST-requests"
  type        = string
  default     = "https://openvpn-statistic.automat-it.io/prod/openvpn-users"
}
variable "openvpn_userlist_scheduller" {
  description = "Cron scheduler value"
  type        = string
  default     = "cron(0 0 8 ? * * *)"
}
