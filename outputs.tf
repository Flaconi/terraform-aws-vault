# -------------------------------------------------------------------------------------------------
# ELB
# -------------------------------------------------------------------------------------------------
output "elb_fqdn_vault" {
  value       = module.vault_elb.fqdn
  description = "The AWS provided CNAME of the Vault ELB."
}

output "elb_route53_public_dns_name_vault" {
  value       = module.vault_elb.route53_public_dns_name
  description = "The Route53 name attached to the Vault ELB, if spcified in variables."
}

# -------------------------------------------------------------------------------------------------
# Autoscaling Groups
# -------------------------------------------------------------------------------------------------
output "asg_name_consul_cluster" {
  value       = module.consul_cluster.asg_name
  description = "Autoscaling group name of the Consul cluster."
}

output "asg_name_vault_cluster" {
  value       = module.vault_cluster.asg_name
  description = "Autoscaling group name of the Vault cluster."
}

# -------------------------------------------------------------------------------------------------
# Launch Configuration
# -------------------------------------------------------------------------------------------------
output "launch_config_name_consul_cluster" {
  value       = module.consul_cluster.launch_config_name
  description = "Launch configuration name of the Consul cluster."
}

output "launch_config_name_vault_cluster" {
  value       = module.vault_cluster.launch_config_name
  description = "Launch configuration name of the Vault cluster."
}

# -------------------------------------------------------------------------------------------------
# IAM
# -------------------------------------------------------------------------------------------------
output "iam_role_arn_consul_cluster" {
  value       = module.consul_cluster.iam_role_arn
  description = "IAM role ARN attached to the Consul cluster."
}

output "iam_role_arn_vault_cluster" {
  value       = module.vault_cluster.iam_role_arn
  description = "IAM role ARN attached to the Vault cluster."
}

output "iam_role_id_consul_cluster" {
  value       = module.consul_cluster.iam_role_id
  description = "IAM role ID attached to the Consul cluster."
}

output "iam_role_id_vault_cluster" {
  value       = module.vault_cluster.iam_role_id
  description = "IAM role ID attached to the Vault cluster."
}

# -------------------------------------------------------------------------------------------------
# Security Groups
# -------------------------------------------------------------------------------------------------
output "security_group_id_consul_cluster" {
  value       = module.consul_cluster.security_group_id
  description = "Security group ID of the Consul cluster to attach to other security group rules."
}

output "security_group_id_vault_cluster" {
  value       = module.vault_cluster.security_group_id
  description = "Security group ID of the Vault cluster to attach to other security group rules."
}

# -------------------------------------------------------------------------------------------------
# AWS
# -------------------------------------------------------------------------------------------------
output "aws_region" {
  value       = data.aws_region.current.name
  description = "Used AWS region."
}

