locals {
  # Templates for SSM documents
  openvpn_ssm_document_contents   = templatefile("${path.module}/templates/openvpn-ssm-document-template.tpl", { subnets = var.vpn_routes_cidrs, admin_port = var.admin_port, eip = aws_eip.openvpn.public_ip })
  openvpn_ssm_certbot_contents    = templatefile("${path.module}/templates/openvpn-ssm-certbot-template.tpl", { project_domain = var.project_domain })
  openvpn_ssm_users_list          = templatefile("${path.module}/templates/openvpn_sm_users_list-template.tpl", { api_url = var.openvpn_userlist_apigw_url })
  openvpn_ssm_disable_auto_update = templatefile("${path.module}/templates/openvpn_disable_auto_update.tpl", {})
}

### Data source: Latest OpenVPN AS AMI in the region (needs manual subscription)
data "aws_ami" "openvpn" {
  executable_users   = ["all"]
  owners             = ["aws-marketplace"]
  most_recent        = true
  include_deprecated = true
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "owner-id"
    values = [var.owner_id]
  }
  filter {
    name   = "product-code"
    values = [var.product_code]
  }
}

### Random Password: OpenVPN AS admin user
resource "random_password" "openvpn-admin" {
  length           = 12
  special          = true
  override_special = "@!,."
}

### Security Group: OpenVPN instance
resource "aws_security_group" "openvpn" {
  name        = "${var.name_prefix}-OpenVPN-SG"
  description = "SG for OpenVPN"
  vpc_id      = var.vpc_id
  # No egress restrictions
  egress {
    description = "Allow all outbound traffic"
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(var.tags, {
    Name = "${var.name_prefix}-OpenVPN-SG"
  })
}

### SecurityGroup rule: Allow OpenVPN protocol
resource "aws_security_group_rule" "openvpn-proto" {
  count             = length(var.vpn_access_cidrs)
  security_group_id = aws_security_group.openvpn.id
  type              = "ingress"
  description       = "Access to OpenVPN over UDP"
  protocol          = "udp"
  from_port         = 1194
  to_port           = 1194
  cidr_blocks       = [var.vpn_access_cidrs[count.index]]
}

### SecurityGroup rule: Allow HTTP for Certbot
resource "aws_security_group_rule" "certbot" {
  count             = var.vpn_create_ssl ? 1 : 0
  security_group_id = aws_security_group.openvpn.id
  type              = "ingress"
  description       = "Access to Certbot over HTTP"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_blocks       = ["0.0.0.0/0"]
}

### SecurityGroup rule: Allow SSH access to OpenVPN server
resource "aws_security_group_rule" "openvpn-ssh" {
  count             = length(var.ssh_access_cidrs)
  security_group_id = aws_security_group.openvpn.id
  type              = "ingress"
  description       = "Access to server over SSH"
  protocol          = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_blocks       = [var.ssh_access_cidrs[count.index]]
}

### SecurityGroup rule: Allow access to OpenVPN AS Web UI
# ... admin
resource "aws_security_group_rule" "openvpn-webui-user" {
  count             = length(var.vpn_access_cidrs)
  security_group_id = aws_security_group.openvpn.id
  type              = "ingress"
  description       = "Access to OpenVPN over TCP"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_blocks       = [var.vpn_access_cidrs[count.index]]
}

### IAM role and policy
# Get builtin AWS SSM policy ARN
data "aws_iam_policy" "amazon-ssm-managed-instance-core" {
  name = "AmazonSSMManagedInstanceCore"
}

# create IAM role for SSM+OpenVPN instance
resource "aws_iam_role" "role-openvpn-ssm" {
  name = "${var.name_prefix}-OpenVPN-SSM-Role"
  assume_role_policy = jsonencode(
    {
      Version : "2012-10-17"
      Statement : [
        {
          Action : "sts:AssumeRole"
          Effect : "Allow"
          Principal : {
            Service : "ec2.amazonaws.com"
          }
        }
      ]
    }
  )
}

# Attach the builtin policy to our SSM+OVPN role
resource "aws_iam_role_policy_attachment" "openvpn-ssm-role-core-policy-attach" {
  role       = aws_iam_role.role-openvpn-ssm.name
  policy_arn = data.aws_iam_policy.amazon-ssm-managed-instance-core.arn
}

# Policy document for SSM SSH session logging
data "aws_iam_policy_document" "openvpn-session-logging-policy" {
  count = var.enable_ssh_logging ? 1 : 0
  statement {
    sid = "CloudWatchAccessForSessionManager"
    actions = [
      "logs:PutLogEvents",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams"
    ]
    resources = ["*"]
  }
  statement {
    sid = "KMSEncryptionForSessionManager"
    actions = [
      "kms:DescribeKey",
      "kms:GenerateDataKey",
      "kms:Decrypt",
      "kms:Encrypt"
    ]
    resources = [var.ssmkey_arn]
  }
  statement {
    sid       = "S3BucketAccessForSessionManager"
    actions   = ["s3:PutObject"]
    resources = ["${var.session_logs_bucket_arn}/*"]
  }
  statement {
    sid       = "S3BucketEncryptionForSessionManager"
    actions   = ["s3:GetEncryptionConfiguration"]
    resources = [var.session_logs_bucket_arn]
  }
}

# Policy for SSM SSH session logging
resource "aws_iam_policy" "openvpn-session-logging-policy" {
  count  = var.enable_ssh_logging ? 1 : 0
  name   = "${var.name_prefix}-OpenVPN-session-logging-policy"
  policy = data.aws_iam_policy_document.openvpn-session-logging-policy[0].json
}

# Attach the openvpn_session_logging_policy policy to our SSM+OVPN role
resource "aws_iam_role_policy_attachment" "openvpn-session-logging-policy-attach" {
  count      = var.enable_ssh_logging ? 1 : 0
  role       = aws_iam_role.role-openvpn-ssm.name
  policy_arn = aws_iam_policy.openvpn-session-logging-policy[0].arn
}

# Create IAM instance profile for the openvpn instance
# i.e. attach our role to the instance
resource "aws_iam_instance_profile" "openvpn-iam-ssm-instance-profile" {
  name = "${var.name_prefix}-OpenVPN-Instance-Profile"
  role = aws_iam_role.role-openvpn-ssm.name
}

resource "aws_kms_key" "ebs-key" {
  count                    = var.encrypt_ebs == false || var.kms_key_id != null ? 0 : 1
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  enable_key_rotation      = var.kms_rotation
}

resource "aws_kms_alias" "ebs-key-alias" {
  count         = var.encrypt_ebs == false || var.kms_key_id != null ? 0 : 1
  name          = "alias/${var.name_prefix}-OpenVPN-EBS"
  target_key_id = aws_kms_key.ebs-key[0].key_id
}


### EC2 Instance: OpenVPN
resource "aws_instance" "openvpn" {
  ami                    = data.aws_ami.openvpn.image_id
  instance_type          = var.instance_type
  source_dest_check      = false # Required
  vpc_security_group_ids = [aws_security_group.openvpn.id]
  # assign SSM+OVPN IAM instance profile to this instance
  iam_instance_profile = aws_iam_instance_profile.openvpn-iam-ssm-instance-profile.name
  key_name             = var.allow_ssh ? var.ssh_key : null
  subnet_id            = var.subnet_id
  monitoring           = var.enable_detailed_monitoring
  ebs_optimized        = var.ebs_optimized
  root_block_device {
    volume_type = "gp3"
    volume_size = var.root_ebs_size
    encrypted   = var.encrypt_ebs
    kms_key_id  = var.kms_key_id != null ? var.kms_key_id : var.encrypt_ebs ? aws_kms_key.ebs-key[0].arn : null
  }
  # Tune OpenVPN AS automatically
  user_data = <<-EOF
    #!/bin/bash
    systemctl stop unattended-upgrades
    apt update
    apt-mark unhold openvpn-as
    yes | apt upgrade
    apt-mark hold openvpn-as
    apt -y install awscli
    systemctl start unattended-upgrades
    admin_user=${var.admin_user}
    admin_pw=${random_password.openvpn-admin.result}
    reroute_dns=1
    reroute_gw=0
    EOF
  tags = merge(var.tags, {
    Name = "${var.name_prefix}-OpenVPN"
  })
  # Ignore changes to user data, to allow cleaning up of plaintext passwords
  lifecycle {
    ignore_changes = [
      user_data,
      user_data_base64,
      ami
    ]
  }
}

# Wait a bit after instance startup to let user-data finish
resource "time_sleep" "wait-after-instance-creation" {
  count           = var.configure_vpn ? 1 : 0
  create_duration = "120s"
  triggers = {
    instance_id = aws_instance.openvpn.id
  }
}

### SSM
# create SSM for disabling auto updates
resource "aws_ssm_document" "ssm-openvpn-disauto-document" {
  name          = "${var.name_prefix}-ssm-openvpn-disauto-document"
  document_type = "Command"
  content       = local.openvpn_ssm_disable_auto_update

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-OpenVPN-ssm-openvpn-disauto-document"
  })
}

# create SSM for network configuration
resource "aws_ssm_document" "ssm-openvpn-document" {
  name          = "${var.name_prefix}-OpenVPN-ssm-document"
  document_type = "Command"
  content       = local.openvpn_ssm_document_contents

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-OpenVPN-ssm-document"
  })
}

# create SSM for certbot configuration
resource "aws_ssm_document" "ssm-openvpn-certbot-document" {
  name          = "${var.name_prefix}-OpenVPN-certbot-ssm-document"
  document_type = "Command"
  content       = local.openvpn_ssm_certbot_contents

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-OpenVPN-certbot-ssm-document"
  })
}

# create SSM for openvpn userslist sender configuration
resource "aws_ssm_document" "ssm-openvpn-users-list-document" {
  name          = "${var.name_prefix}-OpenVPN-users-list-ssm-document"
  document_type = "Command"
  content       = local.openvpn_ssm_users_list

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-OpenVPN-users-list-ssm-document"
  })
}

# associate SSM documents with our OpenVPN instance after it was created
resource "aws_ssm_association" "openvpn-ssm-document-association" {
  # By default, when you create a new association,
  # the system runs it immediately after it is created
  # https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-ssm-association.html#cfn-ssm-association-applyonlyatcroninterval
  count      = var.configure_vpn ? 1 : 0
  depends_on = [time_sleep.wait-after-instance-creation]
  name       = aws_ssm_document.ssm-openvpn-document.name
  targets {
    key    = "InstanceIds"
    values = [aws_instance.openvpn.id]
  }
}

resource "aws_ssm_association" "ssm-openvpn-disauto-document" {
  depends_on = [time_sleep.wait-after-instance-creation]
  name       = aws_ssm_document.ssm-openvpn-disauto-document.name

  targets {
    key    = "InstanceIds"
    values = [aws_instance.openvpn.id]
  }
}

resource "aws_ssm_association" "openvpn-ssm-certbot-document-association" {
  count      = var.vpn_create_ssl ? 1 : 0
  depends_on = [time_sleep.wait-after-instance-creation]
  name       = aws_ssm_document.ssm-openvpn-certbot-document.name
  targets {
    key    = "InstanceIds"
    values = [aws_instance.openvpn.id]
  }
}

# Wait a bit to let SSM run the commands listed in SSM Document
resource "time_sleep" "wait-after-ssm-association" {
  count           = var.configure_vpn ? 1 : 0
  create_duration = "120s"
  triggers = {
    association_id  = aws_ssm_association.openvpn-ssm-document-association[0].association_id
    aws_instance_id = aws_instance.openvpn.id
  }
}

### Download ovpn client profile to a local folder
data "http" "openvpn-autologin-profile" {
  count    = var.configure_vpn && var.ovpn_download ? 1 : 0
  url      = "https://${aws_eip.openvpn.public_ip}/rest/GetAutologin"
  insecure = true
  request_headers = {
    Authorization : "Basic ${base64encode("${var.admin_user}:${random_password.openvpn-admin.result}")}"
  }
  depends_on = [time_sleep.wait-after-ssm-association]
}

resource "local_sensitive_file" "openvpn-autologin-profile" {
  count           = var.configure_vpn && var.ovpn_download ? 1 : 0
  content         = data.http.openvpn-autologin-profile[0].response_body
  file_permission = "0644"
  filename        = "${path.cwd}/openvpn.ovpn"
}

### Elastic IP
resource "aws_eip" "openvpn" {
  domain = "vpc"

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-OpenVPN-EIP"
  })
}

resource "aws_eip_association" "openvpn" {
  allocation_id = aws_eip.openvpn.id
  instance_id   = aws_instance.openvpn.id
}

### Create a Maintenance Window for ssm-openvpn-users-list-document
resource "aws_ssm_maintenance_window" "window" {
  name              = "OpenVPN-UsersList"
  schedule          = var.openvpn_userlist_scheduller
  duration          = 1
  cutoff            = 0
  schedule_timezone = "Europe/Kiev"

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-OpenVPN-users-list"
  })
}

resource "aws_ssm_maintenance_window_target" "target" {
  window_id     = aws_ssm_maintenance_window.window.id
  name          = "OpenVPN-UsersList-Target"
  resource_type = "INSTANCE"
  targets {
    key    = "InstanceIds"
    values = [aws_instance.openvpn.id]
  }
}

resource "aws_ssm_maintenance_window_task" "task" {
  window_id       = aws_ssm_maintenance_window.window.id
  name            = "OpenVPN-UsersList-Task"
  max_concurrency = 1
  max_errors      = 1
  priority        = 1
  task_arn        = "${var.name_prefix}-OpenVPN-users-list-ssm-document"
  task_type       = "RUN_COMMAND"
  targets {
    key    = "InstanceIds"
    values = [aws_instance.openvpn.id]
  }
}
