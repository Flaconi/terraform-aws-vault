# -------------------------------------------------------------------------------------------------
# Placement (required)
# -------------------------------------------------------------------------------------------------
variable "vpc_id" {
  description = "The ID of the VPC in which to deploy the cluster"
}

variable "subnet_ids" {
  description = "The subnet IDs into which the EC2 Instances should be deployed. You should typically pass in one subnet ID per node in the cluster_size variable. We strongly recommend that you run Vault in private subnets. At least one of var.subnet_ids or var.availability_zones must be non-empty."
}

# -------------------------------------------------------------------------------------------------
# Operating System (required)
# -------------------------------------------------------------------------------------------------
variable "ami_id" {
  description = "The ID of the AMI to run in this cluster. Should be an AMI that had Vault installed and configured by the install-vault module."
}

variable "user_data" {
  description = "A User Data script to execute while the server is booting. We recommend passing in a bash script that executes the run-vault script, which should have been installed in the AMI by the install-vault module."
}

# -------------------------------------------------------------------------------------------------
# Cluster Nodes (optional)
# -------------------------------------------------------------------------------------------------
variable "instance_type" {
  description = "The type of EC2 Instances to run for each node in the cluster (e.g. t2.micro)."
  default     = "t2.micro"
}

variable "cluster_size" {
  description = "The number of nodes to have in the cluster. We strongly recommend setting this to 3 or 5."
  default     = 3
}

variable "tenancy" {
  description = "The tenancy of the instance. Must be one of: default or dedicated."
  default     = "default"
}

variable "root_volume_ebs_optimized" {
  description = "If true, the launched EC2 instance will be EBS-optimized."
  default     = false
}

variable "root_volume_type" {
  description = "The type of volume. Must be one of: standard, gp2, or io1."
  default     = "standard"
}

variable "root_volume_size" {
  description = "The size, in GB, of the root EBS volume."
  default     = 50
}

variable "root_volume_delete_on_termination" {
  description = "Whether the volume should be destroyed on instance termination."
  default     = true
}

# -------------------------------------------------------------------------------------------------
# Autoscaling (optional)
# -------------------------------------------------------------------------------------------------
variable "termination_policies" {
  description = "A list of policies to decide how the instances in the auto scale group should be terminated. The allowed values are OldestInstance, NewestInstance, OldestLaunchConfiguration, ClosestToNextInstanceHour, Default."
  default     = "Default"
}

variable "wait_for_capacity_timeout" {
  description = "A maximum duration that Terraform should wait for ASG instances to be healthy before timing out. Setting this to '0' causes Terraform to skip all Capacity Waiting behavior."
  default     = "10m"
}

variable "health_check_type" {
  description = "Controls how health checking is done. Must be one of EC2 or ELB."
  default     = "EC2"
}

variable "health_check_grace_period" {
  description = "Time, in seconds, after instance comes into service before checking health."
  default     = 60
}

# -------------------------------------------------------------------------------------------------
# Security groups (required)
# -------------------------------------------------------------------------------------------------
variable "elb_security_group_id" {
  description = "ID of the security group of a public ELB from which you can API access the Vault instances."
}

variable "ssh_security_group_ids" {
  description = "IDs of the security groups of a bastion ssh instance from where you can ssh into the Vault instances."
  type        = list(string)
}

variable "consul_security_group_id" {
  description = "ID of the security group of the Consul instances to allow traffic from Consul into Vault."
}

# -------------------------------------------------------------------------------------------------
# Tagging/Naming (required)
# -------------------------------------------------------------------------------------------------
variable "cluster_name" {
  description = "The name of the Vault cluster (e.g. vault-stage). This variable is used to namespace all resources created by this module."
}

# -------------------------------------------------------------------------------------------------
# Tagging/Naming (optional)
# -------------------------------------------------------------------------------------------------
variable "tags" {
  description = "Tags to attach to all AWS resources"
  type        = map(string)
  default     = {}
}

# -------------------------------------------------------------------------------------------------
# S3 backend (optional)
# -------------------------------------------------------------------------------------------------
variable "enable_s3_backend" {
  description = "Whether to configure an S3 storage backend in addition to Consul."
  default     = false
}

variable "s3_bucket_name" {
  description = "The name of the S3 bucket in the same region to use as a storage backend. Only used if 'enable_s3_backend' is set to true."
  default     = ""
}

variable "enable_s3_backend_encryption" {
  description = "Whether to configure the S3 storage backend to be encrypted with a KMS key."
  default     = false
}

variable "kms_alias_name" {
  description = "The name of the KMS key that is used for S3 storage backend encryption."
  default     = ""
}

