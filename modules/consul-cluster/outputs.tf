output "asg_name" {
  value       = aws_autoscaling_group.autoscaling_group.name
  description = "Name of the Consul autoscaling group"
}

output "cluster_size" {
  value       = aws_autoscaling_group.autoscaling_group.desired_capacity
  description = "Number of Consul nodes"
}

# output "launch_config_name" {
#   value       = aws_launch_configuration.launch_configuration.name
#   description = "Name of the Consul launch configuration"
# }

output "launch_template" {
  value       = aws_launch_configuration.launch_template.name
  description = "Name of the Vault launch_template"
}
output "iam_role_arn" {
  value       = aws_iam_role.instance_role.arn
  description = "ARN of the IAM role attached to the Consul instance."
}

output "iam_role_id" {
  value       = aws_iam_role.instance_role.id
  description = "ID of the IAM role attached to the Consul instance."
}

output "iam_role_name" {
  value       = aws_iam_role.instance_role.name
  description = "Name of the IAM role attached to the Consul instance."
}

output "security_group_id" {
  value       = module.attach_security_group.security_group_id
  description = "Security group ID to attach to other security group rules as destination."
}
