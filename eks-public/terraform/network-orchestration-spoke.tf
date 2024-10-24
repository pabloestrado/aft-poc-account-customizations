resource "aws_cloudformation_stack" "spoke" {
  name         = "network-orchestration-spoke"
  template_url = "https://solutions-reference.s3.amazonaws.com/network-orchestration-for-aws-transit-gateway/latest/network-orchestration-spoke.template"

  capabilities = ["CAPABILITY_NAMED_IAM"]

  parameters = {
    HubAccount = "390403900367"
  }

}
