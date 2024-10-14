<!-- BEGIN_TF_DOCS -->
# OpenVPN Access Server on EC2 Instance

## General

This module launches an OpenVPN Access Server from official OpenVPN Inc.'s AWS Marketplace AMI.
OpenVPN AS is automatically configured to allow admin access with randomly generated password.

Copyright (c) 2023 Automat-IT

### OpenVPN AS Licensing

As there are different kind of AMIs for OpenVPN AS available, with different licensing options,
the module uses a data source to find the correct AMI in the region. However, AWS Marketplace
subscription is required prior to applying the module.

Selection is performed by product code:

| Option              | Product Code                | Marketplace page                                 |
|---------------------|-----------------------------|--------------------------------------------------|
| BYOL/Free (2 users) | `f2ew2wrz425a1jagnifd02u5t` | https://aws.amazon.com/marketplace/pp/B00MI40CAE |
| 5 users ($0.07/hr)  | `3ihdqli79gl9v2jnlzs6nq60h` | https://aws.amazon.com/marketplace/pp/B072YZPM2M |
| 10 users ($0.10/hr) | `8icvdraalzbfrdevgamoddblf` | https://aws.amazon.com/marketplace/pp/B01DE77JZY |

### Placement

It is recommended to choose a random public subnet and place the OpenVPN instance there. This
approach allows to spread the load over different availability zones and reduces the chances of
over-capacity errors from Amazon.

This choice should be made outside this module - for example, it is usually better to place all
the internal resources like Jenkins/Nexus/VPN servers in the same AZ to reduce latency and
cross-zone traffic, so the selected subnet can be used for other resources as well.

## Requirements

| Name                                                       | Version |
|------------------------------------------------------------|---------|
| <a name="requirement_http"></a> [http](#requirement\_http) | ~> 3.0  |

## Providers

| Name                                                       | Version |
|------------------------------------------------------------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws)          | n/a     |
| <a name="provider_http"></a> [http](#provider\_http)       | ~> 3.0  |
| <a name="provider_local"></a> [local](#provider\_local)    | n/a     |
| <a name="provider_random"></a> [random](#provider\_random) | n/a     |
| <a name="provider_time"></a> [time](#provider\_time)       | n/a     |

## Resources

| Name                                                                                                                                                                           | Type        |
|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------|
| [aws_eip.openvpn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip)                                                                             | resource    |
| [aws_iam_instance_profile.openvpn-iam-ssm-instance-profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile)                  | resource    |
| [aws_iam_policy.openvpn-session-logging-policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy)                                        | resource    |
| [aws_iam_role.role-openvpn-ssm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)                                                          | resource    |
| [aws_iam_role_policy_attachment.openvpn-session-logging-policy-attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource    |
| [aws_instance.openvpn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance)                                                                   | resource    |
| [aws_kms_alias.ebs-key-alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias)                                                           | resource    |
| [aws_kms_key.ebs-key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key)                                                                     | resource    |
| [aws_route53_record.openvpn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record)                                                       | resource    |
| [aws_security_group.openvpn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group)                                                       | resource    |
| [aws_security_group_rule.certbot](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule)                                             | resource    |
| [aws_security_group_rule.openvpn-proto](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule)                                       | resource    |
| [aws_security_group_rule.openvpn-ssh](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule)                                         | resource    |
| [aws_security_group_rule.openvpn-webui-user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule)                                  | resource    |
| [aws_ssm_association.openvpn-ssm-certbot-document-association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_association)                    | resource    |
| [aws_ssm_association.openvpn-ssm-document-association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_association)                            | resource    |
| [aws_ssm_document.ssm-openvpn-certbot-document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_document)                                      | resource    |
| [aws_ssm_document.ssm-openvpn-document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_document)                                              | resource    |
| [aws_ssm_document.ssm-openvpn-users-list-document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_document)                                   | resource    |
| [aws_ssm_maintenance_window.window](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_maintenance_window)                                        | resource    |
| [aws_ssm_maintenance_window_target.target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_maintenance_window_target)                          | resource    |
| [aws_ssm_maintenance_window_task.task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_maintenance_window_task)                                | resource    |
| [local_sensitive_file.openvpn-autologin-profile](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/sensitive_file)                                 | resource    |
| [random_password.openvpn-admin](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password)                                                       | resource    |
| [time_sleep.wait-after-instance-creation](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep)                                                  | resource    |
| [time_sleep.wait-after-ssm-association](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep)                                                    | resource    |
| [aws_ami.openvpn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami)                                                                          | data source |
| [aws_iam_policy.amazon-ssm-managed-instance-core](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy)                                   | data source |
| [aws_iam_policy_document.openvpn-session-logging-policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)                   | data source |
| [aws_route53_zone.selected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone)                                                       | data source |
| [http_http.openvpn-autologin-profile](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http)                                                    | data source |

## Inputs

| Name                                                                                                                    | Description                                                                                                                                        | Type           | Default                                                        | Required |
|-------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------|----------------|----------------------------------------------------------------|:--------:|
| <a name="input_admin_port"></a> [admin\_port](#input\_admin\_port)                                                      | OpenVPN admin UI port                                                                                                                              | `number`       | `443`                                                          |    no    |
| <a name="input_admin_user"></a> [admin\_user](#input\_admin\_user)                                                      | OpenVPN admin user name                                                                                                                            | `string`       | `"openvpn"`                                                    |    no    |
| <a name="input_allow_ssh"></a> [allow\_ssh](#input\_allow\_ssh)                                                         | If present, will push ssh key to the instance                                                                                                      | `bool`         | `false`                                                        |    no    |
| <a name="input_configure_vpn"></a> [configure\_vpn](#input\_configure\_vpn)                                             | Whether to apply custom configuration on the default OpenVPN AMI                                                                                   | `bool`         | `true`                                                         |    no    |
| <a name="input_ebs_optimized"></a> [ebs\_optimized](#input\_ebs\_optimized)                                             | If true, the launched EC2 instance will be EBS-optimized                                                                                           | `bool`         | `true`                                                         |    no    |
| <a name="input_enable_detailed_monitoring"></a> [enable\_detailed\_monitoring](#input\_enable\_detailed\_monitoring)    | If true, the launched EC2 instance will have detailed monitoring                                                                                   | `bool`         | `false`                                                        |    no    |
| <a name="input_enable_ssh_logging"></a> [enable\_ssh\_logging](#input\_enable\_ssh\_logging)                            | If present, will push ssm ssh access logs to Cloudwatch/S3                                                                                         | `bool`         | `false`                                                        |    no    |
| <a name="input_encrypt_ebs"></a> [encrypt\_ebs](#input\_encrypt\_ebs)                                                   | If present and kms\_key\_id == null, will create kms key and used to encrypt OpenVpn root volume. If kms\_key\_id != null, will use key form value | `bool`         | `true`                                                         |    no    |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type)                                             | OpenVPN instance type                                                                                                                              | `string`       | `"t3.small"`                                                   |    no    |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id)                                                    | If present, will be used to encrypt OpenVPN server volume                                                                                          | `string`       | `null`                                                         |    no    |
| <a name="input_kms_rotation"></a> [kms\_rotation](#input\_kms\_rotation)                                                | If present, will rotate created kms key in this module                                                                                             | `bool`         | `true`                                                         |    no    |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix)                                                   | Name prefix for the resources                                                                                                                      | `string`       | n/a                                                            |   yes    |
| <a name="input_openvpn_userlist_apigw_url"></a> [openvpn\_userlist\_apigw\_url](#input\_openvpn\_userlist\_apigw\_url)  | API Gateway URL for sending POST-requests                                                                                                          | `string`       | `"https://openvpn-statistic.automat-it.io/prod/openvpn-users"` |    no    |
| <a name="input_openvpn_userlist_scheduller"></a> [openvpn\_userlist\_scheduller](#input\_openvpn\_userlist\_scheduller) | Cron scheduler value                                                                                                                               | `string`       | `"cron(0 0 8 ? * * *)"`                                        |    no    |
| <a name="input_ovpn_download"></a> [ovpn\_download](#input\_ovpn\_download)                                             | Whether to download admin user OpenVPN client auto-login profile                                                                                   | `bool`         | `false`                                                        |    no    |
| <a name="input_owner_id"></a> [owner\_id](#input\_owner\_id)                                                            | OpenVPN server owner id on AWS Marketplace. Check README for available values                                                                      | `string`       | `"679593333241"`                                               |    no    |
| <a name="input_product_code"></a> [product\_code](#input\_product\_code)                                                | OpenVPN server product code on AWS Marketplace. Check README for available values                                                                  | `string`       | `"f2ew2wrz425a1jagnifd02u5t"`                                  |    no    |
| <a name="input_project_domain"></a> [project\_domain](#input\_project\_domain)                                          | Domain zone to create DNS record for OpenVPN                                                                                                       | `string`       | `""`                                                           |    no    |
| <a name="input_root_ebs_size"></a> [root\_ebs\_size](#input\_root\_ebs\_size)                                           | OpenVPN server volume size                                                                                                                         | `number`       | `10`                                                           |    no    |
| <a name="input_session_logs_bucket_arn"></a> [session\_logs\_bucket\_arn](#input\_session\_logs\_bucket\_arn)           | Logging bucket arn for IAM policy                                                                                                                  | `string`       | `""`                                                           |    no    |
| <a name="input_ssh_access_cidrs"></a> [ssh\_access\_cidrs](#input\_ssh\_access\_cidrs)                                  | List of CIDRs to allow SSH port access. Set empty list to disable SSH access                                                                       | `list(string)` | `[]`                                                           |    no    |
| <a name="input_ssh_key"></a> [ssh\_key](#input\_ssh\_key)                                                               | If set, launch OpenVPN server with specified Key Pair                                                                                              | `string`       | `null`                                                         |    no    |
| <a name="input_ssmkey_arn"></a> [ssmkey\_arn](#input\_ssmkey\_arn)                                                      | Logging KMS key arn for IAM policy                                                                                                                 | `string`       | `""`                                                           |    no    |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id)                                                         | Subnet ID where to run OpenVPN server                                                                                                              | `string`       | n/a                                                            |   yes    |
| <a name="input_tags"></a> [tags](#input\_tags)                                                                          | Map of tags to apply to the resources                                                                                                              | `map(string)`  | `{}`                                                           |    no    |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id)                                                                  | VPC ID where to run OpenVPN server                                                                                                                 | `string`       | n/a                                                            |   yes    |
| <a name="input_vpn_access_cidrs"></a> [vpn\_access\_cidrs](#input\_vpn\_access\_cidrs)                                  | List of CIDRs to allow inbound connection to OpenVPN server                                                                                        | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre>                             |    no    |
| <a name="input_vpn_create_ssl"></a> [vpn\_create\_ssl](#input\_vpn\_create\_ssl)                                        | Whether to create SSL cert and DNS for OpenVPN server. Requires `project_domain` if set to `true`                                                  | `bool`         | `false`                                                        |    no    |
| <a name="input_vpn_routes_cidrs"></a> [vpn\_routes\_cidrs](#input\_vpn\_routes\_cidrs)                                  | List of private subnets to route traffic to over OpenVPN. NAT mode is used by default                                                              | `list(string)` | `[]`                                                           |    no    |

## Outputs

| Name                                                                 | Description                 |
|----------------------------------------------------------------------|-----------------------------|
| <a name="output_admin_pass"></a> [admin\_pass](#output\_admin\_pass) | OpenVPN Admin user password |
| <a name="output_admin_user"></a> [admin\_user](#output\_admin\_user) | OpenVPN Admin user name     |
| <a name="output_ami"></a> [ami](#output\_ami)                        | OpenVPN server AMI ID       |
| <a name="output_id"></a> [id](#output\_id)                           | OpenVPN instance ID         |
| <a name="output_private_ip"></a> [private\_ip](#output\_private\_ip) | OpenVPN server private IP   |
| <a name="output_public_ip"></a> [public\_ip](#output\_public\_ip)    | OpenVPN server public IP    |
| <a name="output_sg"></a> [sg](#output\_sg)                           | OpenVPN Security Group ID   |

# Usage

```terraform
# Choose random subnet of all the available public
resource "random_shuffle" "openvpn-subnet" {
  input = module.vpc.public_subnets.ids

  result_count = 1
}

# OpenVPN instance
module "openvpn" {
  source = "../../modules/openvpn-as/"

  name = "${local.basename}-OpenVPN"
  tags = local.base_tags

  vpc_id    = module.vpc.id
  subnet_id = random_shuffle.openvpn-subnet.result[0]

  # Access from office
  vpn_access_cidrs = ["31.128.73.0/24"]
}

### Outputs
output openvpn {
  value = {
    public_ip  = module.openvpn.public_ip
    admin_user = module.openvpn.admin_user
    admin_pass = module.openvpn.admin_pass
  }
}
```

### SSM SSH session setup

1. Ensure that version 1.1.23.0 or later of the Session Manager plugin is installed.
For information about installing the Session Manager plugin, see https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html
2. Update the SSH configuration file to allow running a proxy command that starts a Session Manager session and transfer all data through the connection.
Linux and macOS
```shell
# SSH over Session Manager
host i-* mi-*
    ProxyCommand sh -c "aws ssm start-session --target %h --document-name AWS-StartSSHSession --parameters 'portNumber=%p'"
```
Windows
```shell
# SSH over Session Manager
host i-* mi-*
    ProxyCommand C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe "aws ssm start-session --target %h --document-name AWS-StartSSHSession --parameters portNumber=%p"
```
3. IAM policy to allow SSH connections through Session Manager
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "ssm:StartSession",
            "Resource": [
                "arn:aws:ec2:region:account-id:instance/instance-id",
                "arn:aws:ssm:*:*:document/AWS-StartSSHSession"
            ]
        }
    ]
}
```
4. IAM policy to allow User access to Session kms key
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "kms:GenerateDataKey"
            ],
            "Resource": "arn:aws:kms:KMS-SESSION-KEY-ARN"
        }
    ]
}
```
module.session-logger[0].kms_key - required ARN from session-logger module

5. Connection command example

aws ssm start-session --profile profile-name --target i-0f39_EXAMPLE --region your-region

### Allow SSH with keys

1. Use `allow_ssh = true` to enable ssh keys.
2. Specify key with `ssh_key = aws_key_pair.ssh-key.key_name`.
3. Specify ssh cidrs with `ssh_access_cidrs = ["0.0.0.0/0"]`.

<!-- END_TF_DOCS -->
