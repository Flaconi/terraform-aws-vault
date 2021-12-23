module "attach_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.7.0"

  name        = "${var.cluster_name}-att"
  description = "Null Placeholder security group for other instances to  use as destination to access ${var.cluster_name}"
  vpc_id      = var.vpc_id

  revoke_rules_on_delete = true

  tags = merge(
    {
      "Name" = "${var.cluster_name}-null"
    },
    var.tags,
  )

  ingress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "icmp"
      cidr_blocks = "255.255.255.255/32"
      description = "(NULL) Terraform requires at least one rule in order to fully manage this security rule"
    },
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = -1
      cidr_blocks = "0.0.0.0/0"
      description = "Default AWS egress rule."
    },
  ]
}

module "lc_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.7.0"

  name        = var.cluster_name
  description = "Security group for the ${var.cluster_name} launch configuration"
  vpc_id      = var.vpc_id

  revoke_rules_on_delete = true

  tags = merge(
    {
      "Name" = var.cluster_name
    },
    var.tags,
  )

  ingress_with_source_security_group_id = [
    {
      from_port                = "22"
      to_port                  = "22"
      protocol                 = "tcp"
      source_security_group_id = var.ssh_security_group_id
      description              = "External SSH. Allow SSH access to Vault instances from this security group (from ELB or instance)."
    },
    {
      from_port                = "8301"
      to_port                  = "8301"
      protocol                 = "udp"
      source_security_group_id = var.consul_security_group_id
      description              = "Consul Agent (UDP). Allow the Consul servers to access the Vault Consul agent from this security group (from ELB or instance)."
    },
    {
      from_port                = "8301"
      to_port                  = "8301"
      protocol                 = "tcp"
      source_security_group_id = var.consul_security_group_id
      description              = "Consul Agent (TCP). Allow the Consul servers to access the Vault Consul agent from this security group (from ELB or instance)."
    },
    {
      from_port                = "8200"
      to_port                  = "8200"
      protocol                 = "tcp"
      source_security_group_id = var.elb_security_group_id
      description              = "External API. Allow API access to Vault instances from this security group (from ELB or instances)."
    },
  ]

  ingress_with_self = [
    {
      from_port   = "8301"
      to_port     = "8301"
      protocol    = "udp"
      self        = true
      description = "Consul Agent (UDP). Allow the Vault servers to access the Vault Consul agent from this security group (from ELB or instance)."
    },
    {
      from_port   = "8301"
      to_port     = "8301"
      protocol    = "tcp"
      self        = true
      description = "Consul Agent (TCP). Allow the Vault servers to access the Vault Consul agent from this security group (from ELB or instance)."
    },
    {
      from_port   = "8200"
      to_port     = "8200"
      protocol    = "tcp"
      self        = true
      description = "Self API. Allow vault instances to access their own API."
    },
    {
      from_port   = "8201"
      to_port     = "8201"
      protocol    = "tcp"
      self        = true
      description = "Self HA Cluster. Allow Vault instances to communicate with each other via their HA cluster port."
    },
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = -1
      cidr_blocks = "0.0.0.0/0"
      description = "Default AWS egress rule."
    },
  ]

}
