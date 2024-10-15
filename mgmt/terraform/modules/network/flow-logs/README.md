<!-- BEGIN_TF_DOCS -->
# Terraform module for enabling VPC Flow Logs

Given Terraform module provides you with a functionality to enable VPC Flow Logs for the given VPC.

As the destination for the logs you can choose either CloudWatch log group (default) or S3.

In case of S3 the bucket should already exist and you need to pass its ARN to the module.

In default setup we suggest using CloudWatch and creating dedicated log group. However, it is not required and you can re-use an existing log group by passing its ARN to the module.

## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.flow-vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_flow_log.vpc-flow-log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/flow_log) | resource |
| [aws_iam_role.flow-vpc-iam-role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.flow-vpc-iam-policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| vpc_id | VPC ID where to enable Flow Logs | `string` | n/a | yes |
| cloudwatch_iam_create | Whether to create IAM role for VPC Flow Logs | `bool` | `true` | no |
| cloudwatch_iam_role_arn | The ARN for the IAM role that's used to post flow logs to a CloudWatch Logs log group. When `vpc_flow_destination_type` is set to `s3`, this argument needs to be provided | `string` | `""` | no |
| cloudwatch_log_group_create | Whether to create CloudWatch log group for VPC Flow Logs | `bool` | `true` | no |
| cloudwatch_log_group_kms_key_id | The ARN of the KMS Key to use when encrypting log data for VPC flow logs | `string` | `null` | no |
| cloudwatch_log_group_name_prefix | Specifies the name prefix of CloudWatch Log Group for VPC flow logs | `string` | `"/aws/vpc-flow-log/"` | no |
| cloudwatch_log_group_retention_in_days | Specifies the number of days you want to retain log events in the specified log group for VPC flow logs | `number` | `30` | no |
| destination_arn | The ARN of the CloudWatch log group or S3 bucket where VPC Flow Logs will be pushed. If this ARN is a S3 bucket, the appropriate permissions need to be set on that bucket's policy. When `vpc_flow_log_cloudwatch_log_group_create` is set to `false`, this argument must be provided | `string` | `""` | no |
| destination_type | The type of the logging destination. Valid values: `cloud-watch-logs`, `s3` | `string` | `"cloud-watch-logs"` | no |
| log_format | The fields to include in the flow log record, in the order in which they should appear | `string` | `null` | no |
| max_aggregation_interval | The maximum interval of time during which a flow of packets is captured and aggregated into a flow log record. Valid Values: `60` seconds or `600` seconds | `number` | `600` | no |
| tags | Additional tags for the VPC Flow Logs | `map(string)` | `{}` | no |
| s3_iam_role_arn | The ARN for the IAM role that's used to post flow logs to a S3 bucket. When `vpc_flow_destination_arn` is set to ARN of Cloudwatch Logs, this argument needs to be provided | `string` | `""` | no |
| traffic_type | The type of traffic to capture. Valid values: `ACCEPT`, `REJECT`, `ALL` | `string` | `"ALL"` | no |

## Outputs

| Name | Description |
|------|-------------|
| flow_log | Grouped parameters of VPC Flow Log resource |

## Usage example

```terraform
module "vpc_flow_logs" {
  source = "../../module/network/vpc/flowlogs/"

  vpc_id = module.vpc.id

  tags = {
    Name = "${module.vpc.id}-flow-logs"
  }
}
```

```terraform
module "vpc_flow_logs" {
  source = "../../module/network/vpc/flowlogs/"

  vpc_id           = module.vpc.id
  destination_type = "s3"
  destination_arn  = module.log-bucket[0].bucket.arn

  tags = {
    Name = "${module.vpc.id}-flow-logs"
  }
}
```
<!-- END_TF_DOCS -->