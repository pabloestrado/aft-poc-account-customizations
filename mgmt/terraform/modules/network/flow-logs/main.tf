### Build local variables
locals {
  cloudwatch_iam_create       = var.destination_type != "s3" && var.cloudwatch_iam_create
  cloudwatch_log_group_create = var.destination_type != "s3" && var.cloudwatch_log_group_create

  destination_arn    = local.cloudwatch_log_group_create ? aws_cloudwatch_log_group.flow-vpc[0].arn : var.destination_arn
  cloudwatch_iam_arn = var.destination_type == "cloud-watch-logs" && local.cloudwatch_iam_create ? aws_iam_role.flow-vpc-iam-role[0].arn : var.cloudwatch_iam_role_arn
  iam_role_arn       = var.destination_type == "s3" ? var.s3_iam_role_arn : local.cloudwatch_iam_arn
}

### Flow Log
resource "aws_flow_log" "vpc-flow-log" {
  log_destination_type     = var.destination_type
  log_destination          = local.destination_arn
  log_format               = var.log_format
  iam_role_arn             = local.iam_role_arn
  traffic_type             = var.traffic_type
  vpc_id                   = var.vpc_id
  max_aggregation_interval = var.max_aggregation_interval

  tags = var.tags
}

### Flow Log CloudWatch 
resource "aws_cloudwatch_log_group" "flow-vpc" {
  count = local.cloudwatch_log_group_create ? 1 : 0

  name              = "${var.cloudwatch_log_group_name_prefix}${var.vpc_id}"
  retention_in_days = var.cloudwatch_log_group_retention_in_days
  kms_key_id        = var.cloudwatch_log_group_kms_key_id

  tags = var.tags
}

# IAM Role for CloudWatch
resource "aws_iam_role" "flow-vpc-iam-role" {
  count = local.cloudwatch_iam_create ? 1 : 0

  name_prefix        = "${var.name}-Flow-Logs-Role"
  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "",
        "Effect": "Allow",
        "Principal": {
          "Service": "vpc-flow-logs.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }
  EOF

  tags = var.tags
}

resource "aws_iam_role_policy" "flow-vpc-iam-policy" {
  count = local.cloudwatch_iam_create ? 1 : 0

  name_prefix = "${var.name}-Flow-Logs-Policy"
  role        = aws_iam_role.flow-vpc-iam-role[0].id
  policy      = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ],
        "Effect": "Allow",
        "Resource": "*"
      }
    ]
  }
  EOF
}
