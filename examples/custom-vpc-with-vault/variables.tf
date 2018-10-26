# -------------------------------------------------------------------------------------------------
# AWS Provider (required)
# -------------------------------------------------------------------------------------------------
variable "region" {
  description = "The AWS region this module is strictly bound to."
}

variable "allowed_account_ids" {
  description = "The AWS account id to which this project is strictly bound."
  type        = "list"
}

# -------------------------------------------------------------------------------------------------
# Security (required)
# -------------------------------------------------------------------------------------------------
variable "bastion_ingress_cidr_ssh" {
  description = "List of CIDR's from which you are allowed to ssh into the bastion host."
  type        = "list"
}

variable "vault_ingress_cidr_https" {
  description = "List of CIDR's from which you are allowed to https access the vault cluster."
  type        = "list"
}

# -------------------------------------------------------------------------------------------------
# VPC (required)
# -------------------------------------------------------------------------------------------------
variable "vpc_cidr" {
  description = "The VPC CIDR to use for this VPC."
}

variable "vpc_subnet_azs" {
  description = "A list of AZ's to use to spawn subnets over"
  type        = "list"
}

variable "vpc_private_subnets" {
  description = "A list of private subnet CIDR's"
  type        = "list"
}

variable "vpc_public_subnets" {
  description = "A list of public subnet CIDR's"
  type        = "list"
}

variable "vpc_enable_nat_gateway" {
  description = "A boolean that enables or disables NAT gateways for private subnets"
}

variable "vpc_enable_vpn_gateway" {
  description = "A boolean that enables or disables a VPN gateways for the VPC"
}

# -------------------------------------------------------------------------------------------------
# Resource Naming/Tagging (optional)
# -------------------------------------------------------------------------------------------------
variable "name" {
  description = "The name(-prefix) tag to apply to all AWS resources"
  default     = "vault"
}

variable "tags" {
  description = "A map of additional tags to apply to all AWS resources"
  type        = "map"
  default     = {}
}

variable "vpc_tags" {
  description = "A map of additional tags to apply to the VPC"
  type        = "map"
  default     = {}
}

variable "public_subnet_tags" {
  description = "A map of additional tags to apply to all public subnets"
  type        = "map"

  default = {
    Visibility = "public"
  }
}

variable "private_subnet_tags" {
  description = "A map of additional tags to apply to all private subnets"
  type        = "map"

  default = {
    Visibility = "private"
  }
}

variable "bastion_cluster_name" {
  description = "What to name the Bastion cluster and all of its associated resources"
  default     = "vault-bastion"
}

variable "consul_cluster_name" {
  description = "What to name the Consul server cluster and all of its associated resources"
  default     = "vault-consul"
}

variable "vault_cluster_name" {
  description = "What to name the Vault server cluster and all of its associated resources"
  default     = "vault-vault"
}

# -------------------------------------------------------------------------------------------------
# DNS (optional)
# -------------------------------------------------------------------------------------------------
variable "bastion_route53_public_dns_name" {
  description = "The Route53 public DNS name for the vault ELB. If not set, no Route53 record will be created."
  default     = ""
}

variable "vault_route53_public_dns_name" {
  description = "The Route53 public DNS name for the vault ELB. If not set, no Route53 record will be created."
  default     = ""
}

# -------------------------------------------------------------------------------------------------
# Instances (required)
# -------------------------------------------------------------------------------------------------
variable "ssh_keys" {
  description = "A list of public ssh keys to add to authorized_keys files."
  type        = "list"
}

# -------------------------------------------------------------------------------------------------
# Instances (optional)
# -------------------------------------------------------------------------------------------------
variable "bastion_instance_type" {
  description = "The type of EC2 Instance to run in the Bastion ASG"
  default     = "t2.micro"
}

variable "consul_instance_type" {
  description = "The type of EC2 Instance to run in the Consul ASG"
  default     = "t2.micro"
}

variable "vault_instance_type" {
  description = "The type of EC2 Instance to run in the Vault ASG"
  default     = "t2.micro"
}

variable "bastion_cluster_size" {
  description = "The number of Bastion nodes to deploy."
  default     = 1
}

variable "consul_cluster_size" {
  description = "The number of Consul server nodes to deploy. We strongly recommend using 3 or 5."
  default     = 3
}

variable "vault_cluster_size" {
  description = "The number of Vault server nodes to deploy. We strongly recommend using 3 or 5."
  default     = 3
}
