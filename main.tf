# This module has been copy/pasted from the following repository:
# https://github.com/hashicorp/terraform-aws-vault
#
# After having copy/pasted it, I have done some heavy rewriting.
# Customization was necessary as the default provided module is not production ready:
# https://github.com/hashicorp/terraform-aws-vault/issues/103
#
# Additionally the following pitfalls were discovered:
# * AMI needs to be built by ourselves in order to provide valid SSL certificates
# * Security groups are to open and cannot be easily closed without rewriting the submodules
#   (https://github.com/hashicorp/terraform-aws-vault/issues/107)
# * Security groups are written in a way that Terraform will not detect any manual changes
#
# For the above reasons, also some submodules had to be rewritten (see modules/)
#

# -------------------------------------------------------------------------------------------------
# Terraform Settings
# -------------------------------------------------------------------------------------------------
# Terraform 0.9.5 suffered from https://github.com/hashicorp/terraform/issues/14399, which causes
# this template the conditionals in this template to fail.
terraform {
  required_version = ">= 0.9.3, != 0.9.5"
}

# -------------------------------------------------------------------------------------------------
# TODO: Use custom build AMI.
# -------------------------------------------------------------------------------------------------
# TODO: Create custom AMI baked with our own SSL certificates for HTTPS access.
data "aws_ami" "vault_consul" {
  most_recent = true

  # If we change the AWS Account in which test are run, update this value.
  owners = ["562637147889"]

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "is-public"
    values = ["true"]
  }

  filter {
    name   = "name"
    values = ["vault-consul-ubuntu-*"]
  }
}

# -------------------------------------------------------------------------------------------------
# DEPLOY THE VAULT SERVER CLUSTER
# -------------------------------------------------------------------------------------------------
module "vault_cluster" {
  source = "modules/vault-cluster"

  cluster_name  = "${var.vault_cluster_name}"
  cluster_size  = "${var.vault_cluster_size}"
  instance_type = "${var.vault_instance_type}"

  ami_id    = "${data.aws_ami.vault_consul.image_id}"
  user_data = "${data.template_file.user_data_vault_cluster.rendered}"

  vpc_id     = "${var.vpc_id}"
  subnet_ids = "${var.private_subnet_ids}"

  # Use S3 Storage Backend?
  enable_s3_backend = "${var.enable_s3_backend}"
  s3_bucket_name    = "${var.s3_bucket_name}"

  # Do NOT use the ELB for the ASG health check, or the ASG will assume all sealed instances are
  # unhealthy and repeatedly try to redeploy them.
  # The ELB health check does not work on unsealed Vault instances.
  health_check_type = "EC2"

  # Security groups
  elb_security_group_id    = "${module.vault_elb.security_group_id}"
  consul_security_group_id = "${module.consul_cluster.security_group_id}"
  ssh_security_group_id    = "${var.ssh_security_group_id}"

  tags = "${var.tags}"
}

# -------------------------------------------------------------------------------------------------
# ATTACH IAM POLICIES FOR CONSUL
# To allow our Vault servers to automatically discover the Consul servers, we need to give them the
# IAM permissions from the Consul AWS Module's consul-iam-policies module.
# -------------------------------------------------------------------------------------------------
module "consul_iam_policies_servers" {
  source = "github.com/hashicorp/terraform-aws-consul//modules/consul-iam-policies?ref=v0.4.0"

  iam_role_id = "${module.vault_cluster.iam_role_id}"
}

# -------------------------------------------------------------------------------------------------
# THE USER DATA SCRIPT THAT WILL RUN ON EACH VAULT SERVER WHEN IT'S BOOTING
# This script will configure and start Vault
# -------------------------------------------------------------------------------------------------
data "template_file" "user_data_vault_cluster" {
  template = "${file("${path.module}/user-data-vault.sh")}"

  vars {
    enable_s3_backend        = "${var.enable_s3_backend ? 1 : 0}"
    s3_bucket_region         = "${data.aws_region.current.name}"
    s3_bucket_name           = "${var.s3_bucket_name}"
    consul_cluster_tag_key   = "${local.consul_cluster_tag_key}"
    consul_cluster_tag_value = "${local.consul_cluster_tag_val}"
    ssh_keys                 = "${join("\n", "${var.ssh_keys}")}"
    ssh_user                 = "ubuntu"
  }
}

data "aws_region" "current" {}

# -------------------------------------------------------------------------------------------------
# Vault ELB
# -------------------------------------------------------------------------------------------------
module "vault_elb" {
  source = "github.com/Flaconi/terraform-aws-elb?ref=v0.1.0"

  name       = "${var.vault_cluster_name}"
  vpc_id     = "${var.vpc_id}"
  subnet_ids = "${var.public_subnet_ids}"

  # Listener
  lb_port       = "443"
  instance_port = "8200"

  # Health Checks
  target              = "HTTPS:8200/v1/sys/health?standbyok=true"
  timeout             = "5"
  interval            = "15"
  healthy_threshold   = "2"
  unhealthy_threshold = "2"

  # Security
  inbound_cidr_blocks = "${var.vault_ingress_cidr_https}"

  # DNS
  route53_public_dns_name = "${var.vault_route53_public_dns_name}"

  # https://github.com/hashicorp/terraform-aws-vault/blob/master/modules/vault-elb/main.tf#L104
  # When set to true, if either none of the ELB's EC2 instances are healthy or the ELB itself is
  # unhealthy, Route 53 routes queries to "other resources." But since we haven't defined any other
  # resources, we'd rather avoid any latency due to switchovers and just wait for the ELB and Vault
  # instances to come back online. For more info, see
  # http://docs.aws.amazon.com/Route53/latest/DeveloperGuide/resource-record-sets-values-alias.html#rrsets-values-alias-evaluate-target-health
  public_dns_evaluate_target_health = false

  tags = "${var.tags}"
}

# Attach Vault ASG to Vault ELB
resource "aws_autoscaling_attachment" "vault" {
  autoscaling_group_name = "${module.vault_cluster.asg_name}"
  elb                    = "${data.aws_elb.vault_elb.id}"
}

data "aws_elb" "vault_elb" {
  name = "${module.vault_elb.name}"
}

# -------------------------------------------------------------------------------------------------
# DEPLOY THE CONSUL SERVER CLUSTER
# -------------------------------------------------------------------------------------------------
module "consul_cluster" {
  source = "modules/consul-cluster"

  # Naming/Tagging
  cluster_name  = "${var.consul_cluster_name}"
  cluster_size  = "${var.consul_cluster_size}"
  instance_type = "${var.consul_instance_type}"

  ami_id    = "${data.aws_ami.vault_consul.image_id}"
  user_data = "${data.template_file.user_data_consul.rendered}"

  vpc_id     = "${var.vpc_id}"
  subnet_ids = "${var.private_subnet_ids}"

  # Security groups
  vault_security_group_id = "${module.vault_cluster.security_group_id}"
  ssh_security_group_id   = "${var.ssh_security_group_id}"

  # The EC2 Instances will use these tags to automatically discover each other and form a cluster
  cluster_tag_key   = "${local.consul_cluster_tag_key}"
  cluster_tag_value = "${local.consul_cluster_tag_val}"

  tags = "${var.tags}"
}

# -------------------------------------------------------------------------------------------------
# THE USER DATA SCRIPT THAT WILL RUN ON EACH CONSUL SERVER WHEN IT'S BOOTING
# This script will configure and start Consul
# -------------------------------------------------------------------------------------------------
data "template_file" "user_data_consul" {
  template = "${file("${path.module}/user-data-consul.sh")}"

  vars {
    consul_cluster_tag_key   = "${local.consul_cluster_tag_key}"
    consul_cluster_tag_value = "${local.consul_cluster_tag_val}"
    ssh_keys                 = "${join("\n", "${var.ssh_keys}")}"
    ssh_user                 = "ubuntu"
  }
}
