output "alb_fqdn_vault" {
  value       = module.vault_alb.dns_name
  description = "The AWS provided CNAME of the Vault ALB."
}

output "alb_route53_public_dns_name_vault" {
  value       = var.vault_route53_public_dns_name
  description = "The Route53 name attached to the Vault ALB, if specified in variables."
}

output "asg_name_consul_cluster" {
  value       = module.consul_cluster.asg_name
  description = "Autoscaling group name of the Consul cluster."
}

output "asg_name_vault_cluster" {
  value       = module.vault_cluster.asg_name
  description = "Autoscaling group name of the Vault cluster."
}

output "launch_template_name_consul_cluster" {
  value       = module.consul_cluster.launch_template
  description = "Launch template name of the Consul cluster."
}

output "launch_template_name_vault_cluster" {
  value       = module.vault_cluster.launch_template
  description = "Launch template name of the Vault cluster."
}

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

output "security_group_id_consul_cluster" {
  value       = module.consul_cluster.security_group_id
  description = "Security group ID of the Consul cluster to attach to other security group rules."
}

output "security_group_id_vault_cluster" {
  value       = module.vault_cluster.security_group_id
  description = "Security group ID of the Vault cluster to attach to other security group rules."
}

output "aws_region" {
  value       = data.aws_region.current.name
  description = "Used AWS region."
}
