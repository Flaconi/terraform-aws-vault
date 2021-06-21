# This module has been copy/pasted from the following repository:
# https://github.com/hashicorp/terraform-aws-vault/tree/master/modules/vault-cluster
#
# Security groups have been re-written in order to make sure they are exclusively managed
# by Terraform and any other rules that have been added by hand (or other means) will be
# removed, whenever this module is called.
#
# This is achieved by moving all separately defined rules from 'aws_security_group_rule'
# into a single 'aws_security_group' block.

# -------------------------------------------------------------------------------------------------
# THESE TEMPLATES REQUIRE TERRAFORM VERSION 0.8 AND ABOVE
# -------------------------------------------------------------------------------------------------
terraform {
  required_version = ">= 0.9.3"
}

# -------------------------------------------------------------------------------------------------
# CREATE AN AUTO SCALING GROUP (ASG) TO RUN VAULT
# -------------------------------------------------------------------------------------------------
# NOTE: This block has been kept unchanged.
resource "aws_autoscaling_group" "autoscaling_group" {
  name_prefix = var.cluster_name

  launch_configuration = aws_launch_configuration.launch_configuration.name

  vpc_zone_identifier = flatten(var.subnet_ids)

  # Use a fixed-size cluster
  min_size             = var.cluster_size
  max_size             = var.cluster_size
  desired_capacity     = var.cluster_size
  termination_policies = [var.termination_policies]

  health_check_type         = var.health_check_type
  health_check_grace_period = var.health_check_grace_period
  wait_for_capacity_timeout = var.wait_for_capacity_timeout

  tags = concat(
    [
      {
        "key"                 = "Name"
        "value"               = var.cluster_name
        "propagate_at_launch" = true
      }
    ],
    local.tags_asg_format,
  )
}

# -------------------------------------------------------------------------------------------------
# CREATE LAUNCH CONFIGURATION TO DEFINE WHAT RUNS ON EACH INSTANCE IN THE ASG
# -------------------------------------------------------------------------------------------------
# NOTE: This block has been altered
resource "aws_launch_configuration" "launch_configuration" {
  name_prefix   = "${var.cluster_name}-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  user_data     = var.user_data

  iam_instance_profile = aws_iam_instance_profile.instance_profile.name
  placement_tenancy    = var.tenancy

  # Edit: key has been removed, as we will add our own SSH keys to the launch configuratoin
  #key_name = "${var.ssh_key_name}"

  # Edit: only allow the vault required vault rules and an external group for ssh access
  security_groups = [aws_security_group.lc_security_group.id, aws_security_group.attach_security_group.id]

  #security_groups = ["${concat(list(aws_security_group.lc_security_group.id), var.additional_security_group_ids)}"]

  # Edit: removed dynamic configuration option, we want Vault to be served by an ELB
  associate_public_ip_address = false

  #associate_public_ip_address = "${var.associate_public_ip_address}"

  ebs_optimized = var.root_volume_ebs_optimized
  root_block_device {
    volume_type           = var.root_volume_type
    volume_size           = var.root_volume_size
    delete_on_termination = var.root_volume_delete_on_termination
  }

  # Important note: whenever using a launch configuration with an auto scaling group, you must set
  # create_before_destroy = true. However, as soon as you set create_before_destroy = true in one
  # resource, you must also set it in every resource that it depends on, or you'll get an error
  # about cyclic dependencies (especially when removing resources). For more info, see:
  #
  # https://www.terraform.io/docs/providers/aws/r/launch_configuration.html
  # https://terraform.io/docs/configuration/resources.html
  lifecycle {
    create_before_destroy = true
  }
}

# -------------------------------------------------------------------------------------------------
# CREATE A SECURITY GROUP TO CONTROL WHAT REQUESTS CAN GO IN AND OUT OF EACH EC2 INSTANCE
# -------------------------------------------------------------------------------------------------
# NOTE: This section has been rewritten to use 'aws_security_group' resource.
# CLARIFICATION OF SECURITY GROUPS: https://github.com/hashicorp/terraform-aws-vault/issues/107

# IMPORTANT:
# 1. Vault needs to allow inbound Consul connections. This is done by using the Consuls security
# group as destination in the vault "lc_security_group" rules.
# 2. Consul needs to allow inbound Vault connections. This is done by using the Vaults security
# group as destination in the consul "lc_security_group" rules.
#
# This however creates a circular dependency in Terraform, as both rules need to be created
# and linked to each other.
# In order to overcome this problem, each of the launch configurations attaches to an (almost)
# empty NULL security group that can be used by the other in their "lc_security_group" to act
# as destination.
# Once this behaviour is fixed in Terraform, each second security group will be removed.
# The "attach_security_group" represents the NULL security group that is also exported by this
# module in order to be used by security groups of other machines.
resource "aws_security_group" "attach_security_group" {
  name_prefix = "${var.cluster_name}-att"
  description = "Null Placeholder security group for other instances to  use as destination to access ${var.cluster_name}"
  vpc_id      = var.vpc_id

  # This is the least possible access I came up with.
  # Note, if no rule is defined, Terraform is not going to see any manually made changes.
  # This is why we need at least one ingress and one egress rule here.
  ingress {
    from_port   = "8"
    to_port     = "0"
    protocol    = "icmp"
    cidr_blocks = ["255.255.255.255/32"]
    description = "(NULL) Terraform requires at least one rule in order to fully manage this security rule"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Default AWS egress rule."
  }

  revoke_rules_on_delete = true

  # aws_launch_configuration.launch_configuration in this module sets create_before_destroy to
  # true, which means everything it depends on, including this resource, must set it as well, or
  # you'll get cyclic dependency errors when you try to do a terraform destroy.
  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    {
      "Name" = "${var.cluster_name}-null"
    },
    var.tags,
  )
}

# 8200/tcp - api_port: The port to use for Vault API calls
# 8201/tcp - cluster_port: The port to use for Vault server-to-server communication
# 8301/tcp - consul agent: The port used to handle Consul gossip in the LAN. Required by all Consul agents
# 8301/udp - consul agent: The port used to handle Consul gossip in the LAN. Required by all Consul agents
#   22/tcp - ssh: Allow ssh access to vault instances
#
# See all required rules here: https://github.com/hashicorp/terraform-aws-vault/issues/107
resource "aws_security_group" "lc_security_group" {
  name_prefix = var.cluster_name
  description = "Security group for the ${var.cluster_name} launch configuration"
  vpc_id      = var.vpc_id

  # Vault HA connections (ensure vault instances find themselves and form a cluster)
  ingress {
    from_port   = "8201"
    to_port     = "8201"
    protocol    = "tcp"
    self        = true
    description = "Self HA Cluster. Allow Vault instances to communicate with each other via their HA cluster port."
  }

  # Vault API access (via browser or cli to query the vault)
  ingress {
    from_port   = "8200"
    to_port     = "8200"
    protocol    = "tcp"
    self        = true
    description = "Self API. Allow vault instances to access their own API."
  }

  ingress {
    from_port       = "8200"
    to_port         = "8200"
    protocol        = "tcp"
    security_groups = [var.elb_security_group_id]
    description     = "External API. Allow API access to Vault instances from this security group (from ELB or instances)."
  }

  # Consul Agents for push/pull memberlist (from self)
  # If not set for itself throwing this error in /opt/consul/log/consul-stdout.log:
  # [ERR] memberlist: Push/Pull with i-00276fbd4e248abc5 failed: dial tcp [vault-server-ip]:8301: i/o timeout
  ingress {
    from_port   = "8301"
    to_port     = "8301"
    protocol    = "tcp"
    self        = true
    description = "Consul Agent (TCP). Allow the Vault servers to access the Vault Consul agent from this security group (from ELB or instance)."
  }

  ingress {
    from_port   = "8301"
    to_port     = "8301"
    protocol    = "udp"
    self        = true
    description = "Consul Agent (UDP). Allow the Vault servers to access the Vault Consul agent from this security group (from ELB or instance)."
  }

  # Consul Agents for push/pull memberlist (from Consul)
  # If not set for itself throwing this error in /opt/consul/log/consul-stdout.log:
  # [ERR] memberlist: Push/Pull with i-00276fbd4e248abc5 failed: dial tcp [consul-server-ip]:8301: i/o timeout
  ingress {
    from_port       = "8301"
    to_port         = "8301"
    protocol        = "tcp"
    security_groups = [var.consul_security_group_id]
    description     = "Consul Agent (TCP). Allow the Consul servers to access the Vault Consul agent from this security group (from ELB or instance)."
  }

  ingress {
    from_port       = "8301"
    to_port         = "8301"
    protocol        = "udp"
    security_groups = [var.consul_security_group_id]
    description     = "Consul Agent (UDP). Allow the Consul servers to access the Vault Consul agent from this security group (from ELB or instance)."
  }

  # SSH access from bastion host
  ingress {
    from_port       = "22"
    to_port         = "22"
    protocol        = "tcp"
    security_groups = var.ssh_security_group_ids
    description     = "External SSH. Allow SSH access to Vault instances from this security group (from ELB or instance)."
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Default AWS egress rule."
  }

  revoke_rules_on_delete = true

  # aws_launch_configuration.launch_configuration in this module sets create_before_destroy to
  # true, which means everything it depends on, including this resource, must set it as well, or
  # you'll get cyclic dependency errors when you try to do a terraform destroy.
  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    {
      "Name" = var.cluster_name
    },
    var.tags,
  )
}

# -------------------------------------------------------------------------------------------------
# ATTACH AN IAM ROLE TO EACH EC2 INSTANCE
# We can use the IAM role to grant the instance IAM permissions so we can use the AWS APIs without
# having to figure out how to get our secret AWS access keys onto the box.
# -------------------------------------------------------------------------------------------------
# NOTE: This block has been kept unchanged.
resource "aws_iam_instance_profile" "instance_profile" {
  name_prefix = var.cluster_name
  path        = "/"
  role        = aws_iam_role.instance_role.name

  # aws_launch_configuration.launch_configuration in this module sets create_before_destroy to
  # true, which means everything it depends on, including this resource, must set it as well, or
  # you'll get cyclic dependency errors when you try to do a terraform destroy.
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role" "instance_role" {
  name_prefix        = var.cluster_name
  assume_role_policy = data.aws_iam_policy_document.instance_role.json

  # aws_launch_configuration.launch_configuration in this module sets create_before_destroy to
  # true, which means everything it depends on, including this resource, must set it as well, or
  # you'll get cyclic dependency errors when you try to do a terraform destroy.
  lifecycle {
    create_before_destroy = true
  }
}

data "aws_iam_policy_document" "instance_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# -------------------------------------------------------------------------------------------------
# Policy to allow access to S3
# -------------------------------------------------------------------------------------------------
resource "aws_iam_role_policy" "vault_s3" {
  count = var.enable_s3_backend ? 1 : 0
  name  = "vault_s3"
  role  = aws_iam_role.instance_role.id
  policy = element(
    concat(data.aws_iam_policy_document.vault_s3.*.json, [""]),
    0,
  )
}

data "aws_iam_policy_document" "vault_s3" {
  count = var.enable_s3_backend ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["s3:*"]

    resources = [
      data.aws_s3_bucket.vault_storage[0].arn,
      "${data.aws_s3_bucket.vault_storage[0].arn}/*",
    ]
  }
}

data "aws_s3_bucket" "vault_storage" {
  count  = var.enable_s3_backend ? 1 : 0
  bucket = var.s3_bucket_name
}

# -------------------------------------------------------------------------------------------------
# Policy to allow access to KMS S3 encryption key
# -------------------------------------------------------------------------------------------------
# https://keita.blog/2017/02/21/iam-policy-for-kms-encrypted-remote-terraform-state-in-s3/
resource "aws_iam_role_policy" "vault_s3_kms" {
  count = var.enable_s3_backend && var.enable_s3_backend_encryption ? 1 : 0
  name  = "vault_s3_kms"
  role  = aws_iam_role.instance_role.id
  policy = element(
    concat(data.aws_iam_policy_document.vault_s3_kms.*.json, [""]),
    0,
  )
}

data "aws_iam_policy_document" "vault_s3_kms" {
  count = var.enable_s3_backend && var.enable_s3_backend_encryption ? 1 : 0

  statement {
    effect = "Allow"

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:GenerateDataKey",
    ]

    resources = [
      data.aws_kms_key.vault_encryption[0].arn,
    ]
  }
}

data "aws_kms_key" "vault_encryption" {
  count  = var.enable_s3_backend && var.enable_s3_backend_encryption ? 1 : 0
  key_id = var.kms_alias_name
}

