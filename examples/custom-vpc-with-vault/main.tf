# -------------------------------------------------------------------------------------------------
# VPC
# -------------------------------------------------------------------------------------------------
module "aws_vpc" {
  source = "github.com/Flaconi/terraform-modules-vpc?ref=v0.1.0"

  # VPC Definition
  vpc_cidr               = "${var.vpc_cidr}"
  vpc_subnet_azs         = "${var.vpc_subnet_azs}"
  vpc_private_subnets    = "${var.vpc_private_subnets}"
  vpc_public_subnets     = "${var.vpc_public_subnets}"
  vpc_enable_nat_gateway = "${var.vpc_enable_nat_gateway}"
  vpc_enable_vpn_gateway = "${var.vpc_enable_vpn_gateway}"

  # Resource Naming/Tagging
  name                = "${var.name}"
  bastion_name        = "${var.bastion_cluster_name}"
  tags                = "${var.tags}"
  vpc_tags            = "${var.vpc_tags}"
  public_subnet_tags  = "${var.public_subnet_tags}"
  private_subnet_tags = "${var.private_subnet_tags}"

  # Bastion DNS
  bastion_route53_public_dns_name = "${var.bastion_route53_public_dns_name}"

  # Bastion SSH
  bastion_ssh_keys        = "${var.ssh_keys}"
  bastion_ssh_cidr_blocks = "${var.bastion_ingress_cidr_ssh}"

  # Bastion Size & Type
  bastion_cluster_size  = "${var.bastion_cluster_size}"
  bastion_instance_type = "${var.bastion_instance_type}"
}

# -------------------------------------------------------------------------------------------------
# Vault
# -------------------------------------------------------------------------------------------------
module "aws_vault" {
  source = "../.."

  # Placement
  vpc_id             = "${module.aws_vpc.vpc_id}"
  public_subnet_ids  = "${module.aws_vpc.public_subnets}"
  private_subnet_ids = "${module.aws_vpc.private_subnets}"

  # Resource Naming/Tagging
  name                = "${var.name}"
  tags                = "${var.tags}"
  consul_cluster_name = "${var.consul_cluster_name}"
  vault_cluster_name  = "${var.vault_cluster_name}"

  # Vault DNS
  vault_route53_public_dns_name = "${var.vault_route53_public_dns_name}"

  # Instance size & count
  consul_instance_type = "${var.consul_instance_type}"
  vault_instance_type  = "${var.vault_instance_type}"
  consul_cluster_size  = "${var.consul_cluster_size}"
  vault_cluster_size   = "${var.vault_cluster_size}"

  # Security
  ssh_keys                 = "${var.ssh_keys}"
  ssh_security_group_id    = "${module.aws_vpc.bastion_security_group_id}"
  vault_ingress_cidr_https = "${var.vault_ingress_cidr_https}"
}
