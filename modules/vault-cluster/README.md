# Vault Cluster

This module has been copy/pasted from the following repository:
https://github.com/hashicorp/terraform-aws-vault/tree/master/modules/vault-cluster

Security groups have been re-written in order to make sure they are exclusively managed
by Terraform and any other rules that have been added by hand (or other means) will be
removed, whenever this module is called.

This is achieved by moving all separately defined rules from 'aws_security_group_rule'
into a single 'aws_security_group' block.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| vpc_id | The ID of the VPC in which to deploy the cluster | string | - | yes |
| subnet_ids | The subnet IDs into which the EC2 Instances should be deployed. You should typically pass in one subnet ID per node in the cluster_size variable. We strongly recommend that you run Vault in private subnets. At least one of var.subnet_ids or var.availability_zones must be non-empty. | list | - | yes |
| ami_id | The ID of the AMI to run in this cluster. Should be an AMI that had Vault installed and configured by the install-vault module. | string | - | yes |
| user_data | A User Data script to execute while the server is booting. We recommend passing in a bash script that executes the run-vault script, which should have been installed in the AMI by the install-vault module. | string | - | yes |
| instance_type | The type of EC2 Instances to run for each node in the cluster (e.g. t2.micro). | string | `t2.micro` | no |
| cluster_size | The number of nodes to have in the cluster. We strongly recommend setting this to 3 or 5. | string | `3` | no |
| tenancy | The tenancy of the instance. Must be one of: default or dedicated. | string | `default` | no |
| root_volume_ebs_optimized | If true, the launched EC2 instance will be EBS-optimized. | string | `false` | no |
| root_volume_type | The type of volume. Must be one of: standard, gp2, or io1. | string | `standard` | no |
| root_volume_size | The size, in GB, of the root EBS volume. | string | `50` | no |
| root_volume_delete_on_termination | Whether the volume should be destroyed on instance termination. | string | `true` | no |
| termination_policies | A list of policies to decide how the instances in the auto scale group should be terminated. The allowed values are OldestInstance, NewestInstance, OldestLaunchConfiguration, ClosestToNextInstanceHour, Default. | string | `Default` | no |
| wait_for_capacity_timeout | A maximum duration that Terraform should wait for ASG instances to be healthy before timing out. Setting this to '0' causes Terraform to skip all Capacity Waiting behavior. | string | `10m` | no |
| health_check_type | Controls how health checking is done. Must be one of EC2 or ELB. | string | `EC2` | no |
| health_check_grace_period | Time, in seconds, after instance comes into service before checking health. | string | `60` | no |
| elb_security_group_id | ID of the security group of a public ELB from which you can API access the Vault instances. | string | - | yes |
| ssh_security_group_id | ID of the security group of a bastion ssh instance from where you can ssh into the Vault instances. | string | - | yes |
| consul_security_group_id | ID of the security group of the Consul instances to allow traffic from Consul into Vault. | string | - | yes |
| cluster_name | The name of the Vault cluster (e.g. vault-stage). This variable is used to namespace all resources created by this module. | string | - | yes |
| tags | Tags to attach to all AWS resources | map | `<map>` | no |
| enable_s3_backend | Whether to configure an S3 storage backend in addition to Consul. | string | `false` | no |
| s3_bucket_name | The name of the S3 bucket in the same region to use as a storage backend. Only used if 'enable_s3_backend' is set to true. | string | `` | no |
| enable_s3_backend_encryption | Whether to configure the S3 storage backend to be encrypted with a KMS key. | string | `false` | no |
| kms_alias_name | The name of the KMS key that is used for S3 storage backend encryption. | string | `` | no |

## Outputs

| Name | Description |
|------|-------------|
| asg_name | Name of the Vault autoscaling group |
| cluster_size | Number of Vault nodes |
| launch_config_name | Name of the Vault launch configuration |
| iam_role_arn | ARN of the IAM role attached to the Vault instance. |
| iam_role_id | ID of the IAM role attached to the Vault instance. |
| iam_role_name | Name of the IAM role attached to the Vault instance. |
| security_group_id | Security group ID to attach to other security group rules as destination. |
| s3_bucket_arn | ARN of the S3 bucket if used as storage backend |
