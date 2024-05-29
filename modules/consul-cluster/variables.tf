variable "vpc_id" {
  description = "The ID of the VPC in which to deploy the Consul cluster"
  type        = string
}

variable "subnet_ids" {
  description = "The subnet IDs into which the EC2 Instances should be deployed. We recommend one subnet ID per node in the cluster_size variable. At least one of var.subnet_ids or var.availability_zones must be non-empty."
  type        = list(string)
}

variable "ami_id" {
  description = "The ID of the AMI to run in this cluster. Should be an AMI that had Consul installed and configured by the install-consul module."
  type        = string
}

variable "user_data" {
  description = "A User Data script to execute while the server is booting. We remmend passing in a bash script that executes the run-consul script, which should have been installed in the Consul AMI by the install-consul module."
  type        = string
}

variable "instance_type" {
  description = "The type of EC2 Instances to run for each node in the cluster (e.g. t3.micro)."
  default     = "t3.micro"
  type        = string
}

variable "cluster_size" {
  description = "The number of nodes to have in the Consul cluster. We strongly recommended that you use either 3 or 5."
  default     = 3
  type        = number
}

# variable "tenancy" {
#   description = "The tenancy of the instance. Must be one of: empty string, default or dedicated. For EC2 Spot Instances only empty string or dedicated can be used."
#   default     = ""
#   type        = string
# }

variable "root_volume_ebs_optimized" {
  description = "If true, the launched EC2 instance will be EBS-optimized."
  default     = false
  type        = bool
}

variable "root_volume_type" {
  description = "The type of volume. Must be one of: standard, gp2, or io1."
  default     = "standard"
  type        = string
}

variable "root_volume_size" {
  description = "The size, in GB, of the root EBS volume."
  default     = 50
  type        = number
}

variable "root_volume_delete_on_termination" {
  description = "Whether the volume should be destroyed on instance termination."
  default     = true
  type        = bool
}

variable "termination_policies" {
  description = "A list of policies to decide how the instances in the auto scale group should be terminated. The allowed values are OldestInstance, NewestInstance, OldestLaunchConfiguration, ClosestToNextInstanceHour, Default."
  default     = "Default"
  type        = string
}

variable "wait_for_capacity_timeout" {
  description = "A maximum duration that Terraform should wait for ASG instances to be healthy before timing out. Setting this to '0' causes Terraform to skip all Capacity Waiting behavior."
  default     = "10m"
  type        = string
}

variable "health_check_type" {
  description = "Controls how health checking is done. Must be one of EC2 or ELB."
  default     = "EC2"
  type        = string
}

variable "health_check_grace_period" {
  description = "Time, in seconds, after instance comes into service before checking health."
  default     = 60
  type        = number
}

variable "instance_profile_path" {
  description = "Path in which to create the IAM instance profile."
  default     = "/"
  type        = string
}

variable "ssh_security_group_id" {
  description = "ID of the security group of a bastion ssh instance from where you can ssh into the Consul instances."
  type        = string
}

variable "vault_security_group_id" {
  description = "ID of the security group of the Vault instances to allow traffic from Vault into Consul."
  type        = string
}

variable "cluster_name" {
  description = "The name of the Consul cluster (e.g. consul-stage). This variable is used to namespace all resources created by this module."
  type        = string
}

variable "tags" {
  description = "Tags to attach to all AWS resources"
  type        = map(string)
  default     = {}
}

variable "cluster_tag_key" {
  description = "Add a tag with this key and the value var.cluster_tag_value to each Instance in the ASG. This can be used to automatically find other Consul nodes and form a cluster."
  default     = "consul-servers"
  type        = string
}

variable "cluster_tag_value" {
  description = "Add a tag with key var.clsuter_tag_key and this value to each Instance in the ASG. This can be used to automatically find other Consul nodes and form a cluster."
  default     = "auto-join"
  type        = string
}
