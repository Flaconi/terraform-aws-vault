# -------------------------------------------------------------------------------------------------
# VPC (required)
# -------------------------------------------------------------------------------------------------
variable "vpc_id" {
  description = "The VPC ID into which you want to provision Vault."
}

variable "public_subnet_ids" {
  description = "A list of public subnet IDs into which the Vault ELB will be provisioned."
  type        = "list"
}

variable "private_subnet_ids" {
  description = "A list of private subnet IDs into which Vault and Consul will be provisioned."
  type        = "list"
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
variable "consul_instance_type" {
  description = "The type of EC2 Instance to run in the Consul ASG"
  default     = "t2.micro"
}

variable "vault_instance_type" {
  description = "The type of EC2 Instance to run in the Vault ASG"
  default     = "t2.micro"
}

variable "consul_cluster_size" {
  description = "The number of Consul server nodes to deploy. We strongly recommend using 3 or 5."
  default     = 3
}

variable "vault_cluster_size" {
  description = "The number of Vault server nodes to deploy. We strongly recommend using 3 or 5."
  default     = 3
}

# -------------------------------------------------------------------------------------------------
# Security
# -------------------------------------------------------------------------------------------------
variable "ssh_security_group_id" {
  description = "Security group ID of a bastion (or other EC2 instance) from which you will be allowed to ssh into Vault and Consul."
}

variable "vault_ingress_cidr_https" {
  description = "List of CIDR's from which you are allowed to https access the vault cluster."
  type        = "list"
  default     = ["0.0.0.0/0"]
}
