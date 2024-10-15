### Outputs
output "flow_log" {
  description = "Flow Logs attributes"
  value = {
    # Flow Logs ID
    id = aws_flow_log.vpc-flow-log.id
    # Flow Logs destination: S3 or CloudWatch
    destination_type = var.destination_type
    # Destination ARN
    destination_arn = local.destination_arn
    # Destination IAM Role
    iam_role_arn = local.iam_role_arn
  }
}
