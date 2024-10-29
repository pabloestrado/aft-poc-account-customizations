# resource "aws_cloudformation_stack" "hub" {
#   name         = "network-orchestration-hub"
#   template_url = "https://solutions-reference.s3.amazonaws.com/network-orchestration-for-aws-transit-gateway/latest/network-orchestration-hub.template"

#   capabilities = ["CAPABILITY_NAMED_IAM"]

#   parameters = {
#     OrganizationManagementAccountRoleArn    = "arn:aws:iam::444629336067:role/network-orchestration-org-OrganizationInformationRo-p0ac7QdQDf0Z"
#     PrincipalType                           = "AWS Organization ARN"
#     Principals                              = "arn:aws:organizations::444629336067:organization/o-mmrpss74fy"
#     ConsoleLoginInformationEmail            = "pavlo.romaniuk@automat-it.com"
#     ApprovalNotificationEmail               = "pavlo.romaniuk@automat-it.com"
#     DeployWebUi                             = "Yes"
#     CognitoDomainPrefixParameter            = "aft-sandbox"
#     CognitoSAMLProviderNameParameter        = ""
#     CognitoSAMLProviderMetadataUrlParameter = ""
#   }

# }
