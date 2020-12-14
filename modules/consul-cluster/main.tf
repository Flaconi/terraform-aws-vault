# This module has been copy/pasted from the following repository:
# https://github.com/hashicorp/terraform-aws-consul/tree/master/modules/consul-cluster
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
# CREATE AN AUTO SCALING GROUP (ASG) TO RUN CONSUL
# -------------------------------------------------------------------------------------------------
# NOTE: This block has been kept unchanged.
resource "aws_autoscaling_group" "autoscaling_group" {
  name_prefix = "${var.cluster_name}"

  launch_configuration = "${aws_launch_configuration.launch_configuration.name}"

  vpc_zone_identifier = ["${var.subnet_ids}"]

  # Run a fixed number of instances in the ASG
  min_size             = "${var.cluster_size}"
  max_size             = "${var.cluster_size}"
  desired_capacity     = "${var.cluster_size}"
  termination_policies = ["${var.termination_policies}"]

  health_check_type         = "${var.health_check_type}"
  health_check_grace_period = "${var.health_check_grace_period}"
  wait_for_capacity_timeout = "${var.wait_for_capacity_timeout}"

  tags = [
    {
      key                 = "Name"
      value               = "${var.cluster_name}"
      propagate_at_launch = true
    },
    {
      key                 = "${var.cluster_tag_key}"
      value               = "${var.cluster_tag_value}"
      propagate_at_launch = true
    },
    "${local.tags_asg_format}",
  ]
}

# -------------------------------------------------------------------------------------------------
# CREATE LAUNCH CONFIGURATION TO DEFINE WHAT RUNS ON EACH INSTANCE IN THE ASG
# -------------------------------------------------------------------------------------------------
# NOTE: This block has been altered
resource "aws_launch_configuration" "launch_configuration" {
  name_prefix   = "${var.cluster_name}-"
  image_id      = "${var.ami_id}"
  instance_type = "${var.instance_type}"
  user_data     = "${var.user_data}"

  # Edit: no need for this
  #spot_price = "${var.spot_price}"

  iam_instance_profile = "${aws_iam_instance_profile.instance_profile.name}"
  placement_tenancy    = "${var.tenancy}"

  # Edit: key has been removed, as we will add our own SSH keys to the launch configuratoin
  #key_name = "${var.ssh_key_name}"

  # Edit: only allow the consul required consul rules and an external group for ssh access
  security_groups = ["${aws_security_group.lc_security_group.id}", "${aws_security_group.attach_security_group.id}"]

  #security_groups = ["${concat(list(aws_security_group.lc_security_group.id), var.additional_security_group_ids)}"]

  # Edit: removed dynamic configuration option, we want Consul to be private by default
  associate_public_ip_address = false

  #associate_public_ip_address = "${var.associate_public_ip_address}"

  ebs_optimized = "${var.root_volume_ebs_optimized}"
  root_block_device {
    volume_type           = "${var.root_volume_type}"
    volume_size           = "${var.root_volume_size}"
    delete_on_termination = "${var.root_volume_delete_on_termination}"
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
  vpc_id      = "${var.vpc_id}"

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

  tags = "${merge(map("Name", "${var.cluster_name}-null"), var.tags)}"
}

# 8300/tcp - server_rpc_port: The port used by servers to handle incoming requests from other agents
# 8301/tcp - sef_lan_port: The port used to handle gossip in the LAN. Required by all agents
# 8301/udp - sef_lan_port: The port used to handle gossip in the LAN. Required by all agents
# 8302/tcp - serf_wan_port: The port used by servers to gossip over the WAN to other servers
# 8302/udp - serf_wan_port: The port used by servers to gossip over the WAN to other servers
# (OFF) 8400/tcp - cli_rpc_port: The port used by all agents to handle RPC from the CLI
# 8500/tcp - http_api_port: The port used by clients to talk to the HTTP API
# 8600/tcp - dns_port: The port used to resolve DNS queries
# 8600/udp - dns_port: The port used to resolve DNS queries
#   22/tcp - ssh: Allow ssh access to consul instances
#
# See all required rules here: https://github.com/hashicorp/terraform-aws-vault/issues/107
resource "aws_security_group" "lc_security_group" {
  name_prefix = "${var.cluster_name}"
  description = "Security group for the ${var.cluster_name} launch configuration"
  vpc_id      = "${var.vpc_id}"

  # Consul Access to itself
  ingress {
    from_port   = "8300"
    to_port     = "8300"
    protocol    = "tcp"
    self        = true
    description = "TODO"
  }

  ingress {
    from_port   = "8301"
    to_port     = "8301"
    protocol    = "tcp"
    self        = true
    description = "TODO"
  }

  ingress {
    from_port   = "8301"
    to_port     = "8301"
    protocol    = "udp"
    self        = true
    description = "TODO"
  }

  ingress {
    from_port   = "8302"
    to_port     = "8302"
    protocol    = "tcp"
    self        = true
    description = "TODO"
  }

  ingress {
    from_port   = "8302"
    to_port     = "8302"
    protocol    = "udp"
    self        = true
    description = "TODO"
  }

  ingress {
    from_port   = "8500"
    to_port     = "8500"
    protocol    = "tcp"
    self        = true
    description = "TODO"
  }

  ingress {
    from_port   = "8600"
    to_port     = "8600"
    protocol    = "tcp"
    self        = true
    description = "Self DNS. Allow consul instances to query themselves for DNS."
  }

  ingress {
    from_port   = "8600"
    to_port     = "8600"
    protocol    = "udp"
    self        = true
    description = "Self DNS. Allow consul instances to query themselves for DNS."
  }

  # Access from Vault
  # 8300/tcp
  # 8301/tcp
  # 8302/tcp
  # 8302/udp
  # 8400/tpc
  # 8500/tcp
  # 8600/tcp
  # 8600/udp
  ingress {
    from_port       = "8300"
    to_port         = "8300"
    protocol        = "tcp"
    security_groups = ["${var.vault_security_group_id}"]
    description     = "TODO"
  }

  ingress {
    from_port       = "8301"
    to_port         = "8301"
    protocol        = "tcp"
    security_groups = ["${var.vault_security_group_id}"]
    description     = "TODO"
  }

  ingress {
    from_port       = "8302"
    to_port         = "8302"
    protocol        = "tcp"
    security_groups = ["${var.vault_security_group_id}"]
    description     = "TODO"
  }

  ingress {
    from_port       = "8302"
    to_port         = "8302"
    protocol        = "udp"
    security_groups = ["${var.vault_security_group_id}"]
    description     = "TODO"
  }

  ingress {
    from_port       = "8400"
    to_port         = "8400"
    protocol        = "tcp"
    security_groups = ["${var.vault_security_group_id}"]
    description     = "TODO"
  }

  ingress {
    from_port       = "8500"
    to_port         = "8500"
    protocol        = "tcp"
    security_groups = ["${var.vault_security_group_id}"]
    description     = "TODO"
  }

  ingress {
    from_port       = "8600"
    to_port         = "8600"
    protocol        = "tcp"
    security_groups = ["${var.vault_security_group_id}"]
    description     = "TODO"
  }

  ingress {
    from_port       = "8600"
    to_port         = "8600"
    protocol        = "udp"
    security_groups = ["${var.vault_security_group_id}"]
    description     = "TODO"
  }

  # SSH access from bastion host
  ingress {
    from_port       = "22"
    to_port         = "22"
    protocol        = "tcp"
    security_groups = ["${var.ssh_security_group_ids}"]
    description     = "External SSH. Allow SSH access to Consul instances from this security group (from ELB or instance)."
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

  tags = "${merge(map("Name", var.cluster_name), var.tags)}"
}

# -------------------------------------------------------------------------------------------------
# ATTACH AN IAM ROLE TO EACH EC2 INSTANCE
# We can use the IAM role to grant the instance IAM permissions so we can use the AWS CLI without
# having to figure out how to get our secret AWS access keys onto the box.
# -------------------------------------------------------------------------------------------------
# NOTE: This block has been kept unchanged.
resource "aws_iam_instance_profile" "instance_profile" {
  name_prefix = "${var.cluster_name}"
  path        = "${var.instance_profile_path}"
  role        = "${aws_iam_role.instance_role.name}"

  # aws_launch_configuration.launch_configuration in this module sets create_before_destroy to true, which means
  # everything it depends on, including this resource, must set it as well, or you'll get cyclic dependency errors
  # when you try to do a terraform destroy.
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role" "instance_role" {
  name_prefix        = "${var.cluster_name}"
  assume_role_policy = "${data.aws_iam_policy_document.instance_role.json}"

  # aws_iam_instance_profile.instance_profile in this module sets create_before_destroy to true, which means
  # everything it depends on, including this resource, must set it as well, or you'll get cyclic dependency errors
  # when you try to do a terraform destroy.
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
# THE IAM POLICIES COME FROM THE CONSUL-IAM-POLICIES MODULE
# -------------------------------------------------------------------------------------------------
# NOTE: This block has been altered
module "iam_policies" {
  # Edit: Use remote source
  source = "github.com/hashicorp/terraform-aws-consul//modules/consul-iam-policies?ref=v0.4.0"

  #source = "../modules/consul-iam-policies"

  iam_role_id = "${aws_iam_role.instance_role.id}"
}
