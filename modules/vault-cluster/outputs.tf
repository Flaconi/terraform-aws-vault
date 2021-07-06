output "asg_name" {
  value       = aws_autoscaling_group.autoscaling_group.name
  description = "Name of the Vault autoscaling group"
}

output "cluster_size" {
  value       = aws_autoscaling_group.autoscaling_group.desired_capacity
  description = "Number of Vault nodes"
}

output "launch_config_name" {
  value       = aws_launch_configuration.launch_configuration.name
  description = "Name of the Vault launch configuration"
}

output "iam_role_arn" {
  value       = aws_iam_role.instance_role.arn
  description = "ARN of the IAM role attached to the Vault instance."
}

output "iam_role_id" {
  value       = aws_iam_role.instance_role.id
  description = "ID of the IAM role attached to the Vault instance."
}

output "iam_role_name" {
  value       = aws_iam_role.instance_role.name
  description = "Name of the IAM role attached to the Vault instance."
}

output "security_group_id" {
  value       = module.attach_security_group.security_group_id
  description = "Security group ID to attach to other security group rules as destination."
}

output "s3_bucket_arn" {
  value       = join(",", data.aws_s3_bucket.vault_storage.*.arn)
  description = "ARN of the S3 bucket if used as storage backend"
}

