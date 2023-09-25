variable "vpc_id" {
  description = "The VPC ID into which you want to provision Vault."
  type        = string
}

variable "public_subnet_ids" {
  description = "A list of public subnet IDs into which the Vault ELB will be provisioned."
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "A list of private subnet IDs into which Vault and Consul will be provisioned."
  type        = list(string)
}

variable "name" {
  description = "The name(-prefix) tag to apply to all AWS resources"
  default     = "vault"
  type        = string
}

variable "tags" {
  description = "A map of additional tags to apply to all AWS resources"
  type        = map(string)
  default     = {}
}

variable "consul_cluster_name" {
  description = "What to name the Consul server cluster and all of its associated resources"
  default     = "vault-consul"
  type        = string
}

variable "vault_cluster_name" {
  description = "What to name the Vault server cluster and all of its associated resources"
  default     = "vault-vault"
  type        = string
}

variable "vault_route53_public_dns_name" {
  description = "The Route53 public DNS name for the vault ELB. If not set, no Route53 record will be created."
  default     = ""
  type        = string
}

variable "ssh_keys" {
  description = "A list of public ssh keys to add to authorized_keys files."
  type        = list(string)
}

variable "consul_instance_type" {
  description = "The type of EC2 Instance to run in the Consul ASG"
  default     = "t3.micro"
  type        = string
}

variable "vault_instance_type" {
  description = "The type of EC2 Instance to run in the Vault ASG"
  default     = "t3.micro"
  type        = string
}

variable "consul_cluster_size" {
  description = "The number of Consul server nodes to deploy. We strongly recommend using 3 or 5."
  default     = 3
  type        = number
}

variable "vault_cluster_size" {
  description = "The number of Vault server nodes to deploy. We strongly recommend using 3 or 5."
  default     = 3
  type        = number
}

variable "ssh_security_group_id" {
  description = "Security group ID of a bastion (or other EC2 instance) from which you will be allowed to ssh into Vault and Consul."
  type        = string
}

variable "vault_ingress_cidr_https" {
  description = "List of CIDR's from which you are allowed to https access the vault cluster."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "security_group_names" {
  description = "List of one or more security groups to be added to the load balancer"
  type        = list(string)
  default     = []
}

variable "ssl_certificate_id" {
  description = "ARN of the certificate to be used for the Vault endpoint ELB"
  type        = string
}

variable "enable_s3_backend" {
  description = "Whether to configure an S3 storage backend in the same region in addition to Consul."
  default     = false
  type        = bool
}

variable "s3_bucket_name" {
  description = "The name of the S3 bucket in the same region to use as a storage backend. Only used if 'enable_s3_backend' is set to true."
  default     = ""
  type        = string
}

variable "enable_s3_backend_encryption" {
  description = "Whether to configure the S3 storage backend to be encrypted with a KMS key."
  default     = false
  type        = bool
}

variable "kms_alias_name" {
  description = "The name of the KMS key that is used for S3 storage backend encryption."
  default     = ""
  type        = string
}

variable "ami_id" {
  description = "ID of the AMI to be used for the Consul and Vault instances."
  default     = null
  type        = string
}

variable "ami_owner" {
  description = "AWS account id for the AMI."
  default     = null
  type        = string
}
