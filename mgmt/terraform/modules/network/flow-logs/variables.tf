### Variables
variable "name" {
  type        = string
  description = "Name for IAM Role and IAM Policy"
}
variable "vpc_id" {
  type        = string
  description = "VPC ID where to enable Flow Logs"
}
variable "destination_type" {
  type        = string
  description = "The type of the logging destination. Valid values: `cloud-watch-logs`, `s3`"
  default     = "cloud-watch-logs"
}
variable "cloudwatch_log_group_create" {
  type        = bool
  description = "Whether to create CloudWatch log group for VPC Flow Logs"
  default     = true
}
variable "cloudwatch_log_group_name_prefix" {
  description = "Specifies the name prefix of CloudWatch Log Group for VPC flow logs"
  type        = string
  default     = "/aws/vpc-flow-log/"
}
variable "cloudwatch_log_group_retention_in_days" {
  description = "Specifies the number of days you want to retain log events in the specified log group for VPC flow logs"
  type        = number
  default     = 30
}
variable "cloudwatch_log_group_kms_key_id" {
  description = "The ARN of the KMS Key to use when encrypting log data for VPC flow logs"
  type        = string
  default     = null
}
variable "destination_arn" {
  description = "The ARN of the CloudWatch log group or S3 bucket where VPC Flow Logs will be pushed. If this ARN is a S3 bucket, the appropriate permissions need to be set on that bucket's policy. When `vpc_flow_log_cloudwatch_log_group_create` is set to `false`, this argument must be provided"
  type        = string
  default     = ""
}
variable "cloudwatch_iam_create" {
  type        = bool
  description = "Whether to create IAM role for VPC Flow Logs"
  default     = true
}
variable "cloudwatch_iam_role_arn" {
  description = "The ARN for the IAM role that's used to post flow logs to a CloudWatch Logs log group. When `vpc_flow_destination_type` is set to `s3`, this argument needs to be provided"
  type        = string
  default     = ""
}
variable "s3_iam_role_arn" {
  description = "The ARN for the IAM role that's used to post flow logs to a S3 bucket. When `vpc_flow_destination_arn` is set to ARN of Cloudwatch Logs, this argument needs to be provided"
  type        = string
  default     = ""
}
variable "log_format" {
  type        = string
  description = "The fields to include in the flow log record, in the order in which they should appear"
  default     = null
}
variable "traffic_type" {
  type        = string
  description = "The type of traffic to capture. Valid values: `ACCEPT`, `REJECT`, `ALL`"
  default     = "ALL"
}
variable "max_aggregation_interval" {
  description = "The maximum interval of time during which a flow of packets is captured and aggregated into a flow log record. Valid Values: `60` seconds or `600` seconds"
  type        = number
  default     = 600
}
variable "tags" {
  type        = map(string)
  description = "Additional tags for the VPC Flow Logs"
  default     = {}
}
