# -------------------------------------------------------------------------------------------------
# VPC
# -------------------------------------------------------------------------------------------------
module "aws_vpc" {
  source = "github.com/Flaconi/terraform-modules-vpc?ref=v0.1.0"

  # VPC Definition
  vpc_cidr               = "40.10.0.0/16"
  vpc_subnet_azs         = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
  vpc_private_subnets    = ["40.10.10.0/24", "40.10.11.0/24", "40.10.12.0/24"]
  vpc_public_subnets     = ["40.10.20.0/24", "40.10.21.0/24", "40.10.12.0/24"]
  vpc_enable_nat_gateway = true
  vpc_enable_vpn_gateway = false

  # Resource Naming/Tagging
  name         = "vault-example"
  bastion_name = "vault-example-bastion"

  # Bastion SSH
  bastion_ssh_keys        = ["ssh-ed25519 AAAAC3Nznte5aaCdi1a1Lzaai/tX6Mc2E+S6g3lrClL09iBZ5cW2OZdSIqomcMko 2 mysshkey"]
  bastion_ssh_cidr_blocks = ["0.0.0.0/0"]
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
  name                = "vault-example"
  consul_cluster_name = "vault-example-consul"
  vault_cluster_name  = "vault-example-vault"

  # Security
  ssh_keys                 = ["ssh-ed25519 AAAAC3Nznte5aaCdi1a1Lzaai/tX6Mc2E+S6g3lrClL09iBZ5cW2OZdSIqomcMko 2 mysshkey"]
  ssh_security_group_ids   = ["${module.aws_vpc.bastion_security_group_id}"]
  vault_ingress_cidr_https = ["0.0.0.0/0"]
}
