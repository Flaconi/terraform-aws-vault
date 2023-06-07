# Vault Cluster

This module was inspired by the following repository: [terraform-aws-vault][1].

## Caveats

### Security Groups

See this [GitHub issue][2], for clarifying the purpose of the SGs and their
rules.

__IMPORTANT:__

1. Vault needs to allow inbound Consul connections. This is done by using
   Consul's security group as destination in the vault `lc_security_group`
   rules.
1. Consul needs to allow inbound Vault connections. This is done by using
   Vault's security group as destination in the consul `lc_security_group`
   rules.

This however creates a circular dependency in Terraform, as both rules need to
be created and linked to each other.
In order to overcome this problem, each of the launch configurations attaches
an (almost) empty NULL security group that can be used by the other in their
`lc_security_group` to act as destination.
Once this behaviour is fixed in Terraform, each second security group will be
removed.
The `attach_security_group` represents the NULL security group that is also
exported by this module in order to be used by security groups of other
machines.

[Here][3] are the ports in use and their purpose.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5 |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_attach_security_group"></a> [attach\_security\_group](#module\_attach\_security\_group) | terraform-aws-modules/security-group/aws | 4.7.0 |
| <a name="module_lc_security_group"></a> [lc\_security\_group](#module\_lc\_security\_group) | terraform-aws-modules/security-group/aws | 4.7.0 |

## Resources

| Name | Type |
|------|------|
| [aws_autoscaling_group.autoscaling_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_iam_instance_profile.instance_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.instance_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.vault_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.vault_s3_kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_launch_configuration.launch_configuration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_configuration) | resource |
| [null_resource.tags_as_list_of_maps](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [aws_iam_policy_document.instance_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.vault_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.vault_s3_kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_kms_key.vault_encryption](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/kms_key) | data source |
| [aws_s3_bucket.vault_storage](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/s3_bucket) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC in which to deploy the cluster | `string` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | The subnet IDs into which the EC2 Instances should be deployed. You should typically pass in one subnet ID per node in the cluster\_size variable. We strongly recommend that you run Vault in private subnets. At least one of var.subnet\_ids or var.availability\_zones must be non-empty. | `list(string)` | n/a | yes |
| <a name="input_ami_id"></a> [ami\_id](#input\_ami\_id) | The ID of the AMI to run in this cluster. Should be an AMI that had Vault installed and configured by the install-vault module. | `string` | n/a | yes |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | A User Data script to execute while the server is booting. We recommend passing in a bash script that executes the run-vault script, which should have been installed in the AMI by the install-vault module. | `string` | n/a | yes |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | The type of EC2 Instances to run for each node in the cluster (e.g. t2.micro). | `string` | `"t3.micro"` | no |
| <a name="input_cluster_size"></a> [cluster\_size](#input\_cluster\_size) | The number of nodes to have in the cluster. We strongly recommend setting this to 3 or 5. | `number` | `3` | no |
| <a name="input_tenancy"></a> [tenancy](#input\_tenancy) | The tenancy of the instance. Must be one of: default or dedicated. | `string` | `"default"` | no |
| <a name="input_root_volume_ebs_optimized"></a> [root\_volume\_ebs\_optimized](#input\_root\_volume\_ebs\_optimized) | If true, the launched EC2 instance will be EBS-optimized. | `bool` | `false` | no |
| <a name="input_root_volume_type"></a> [root\_volume\_type](#input\_root\_volume\_type) | The type of volume. Must be one of: standard, gp2, or io1. | `string` | `"standard"` | no |
| <a name="input_root_volume_size"></a> [root\_volume\_size](#input\_root\_volume\_size) | The size, in GB, of the root EBS volume. | `number` | `50` | no |
| <a name="input_root_volume_delete_on_termination"></a> [root\_volume\_delete\_on\_termination](#input\_root\_volume\_delete\_on\_termination) | Whether the volume should be destroyed on instance termination. | `bool` | `true` | no |
| <a name="input_termination_policies"></a> [termination\_policies](#input\_termination\_policies) | A list of policies to decide how the instances in the auto scale group should be terminated. The allowed values are OldestInstance, NewestInstance, OldestLaunchConfiguration, ClosestToNextInstanceHour, Default. | `string` | `"Default"` | no |
| <a name="input_wait_for_capacity_timeout"></a> [wait\_for\_capacity\_timeout](#input\_wait\_for\_capacity\_timeout) | A maximum duration that Terraform should wait for ASG instances to be healthy before timing out. Setting this to '0' causes Terraform to skip all Capacity Waiting behavior. | `string` | `"10m"` | no |
| <a name="input_health_check_type"></a> [health\_check\_type](#input\_health\_check\_type) | Controls how health checking is done. Must be one of EC2 or ELB. | `string` | `"EC2"` | no |
| <a name="input_health_check_grace_period"></a> [health\_check\_grace\_period](#input\_health\_check\_grace\_period) | Time, in seconds, after instance comes into service before checking health. | `number` | `60` | no |
| <a name="input_elb_security_group_id"></a> [elb\_security\_group\_id](#input\_elb\_security\_group\_id) | ID of the security group of a public ELB from which you can API access the Vault instances. | `string` | n/a | yes |
| <a name="input_ssh_security_group_id"></a> [ssh\_security\_group\_id](#input\_ssh\_security\_group\_id) | ID of the security group of a bastion ssh instance from where you can ssh into the Vault instances. | `string` | n/a | yes |
| <a name="input_consul_security_group_id"></a> [consul\_security\_group\_id](#input\_consul\_security\_group\_id) | ID of the security group of the Consul instances to allow traffic from Consul into Vault. | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of the Vault cluster (e.g. vault-stage). This variable is used to namespace all resources created by this module. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to attach to all AWS resources | `map(string)` | `{}` | no |
| <a name="input_enable_s3_backend"></a> [enable\_s3\_backend](#input\_enable\_s3\_backend) | Whether to configure an S3 storage backend in addition to Consul. | `bool` | `false` | no |
| <a name="input_s3_bucket_name"></a> [s3\_bucket\_name](#input\_s3\_bucket\_name) | The name of the S3 bucket in the same region to use as a storage backend. Only used if 'enable\_s3\_backend' is set to true. | `string` | `""` | no |
| <a name="input_enable_s3_backend_encryption"></a> [enable\_s3\_backend\_encryption](#input\_enable\_s3\_backend\_encryption) | Whether to configure the S3 storage backend to be encrypted with a KMS key. | `bool` | `false` | no |
| <a name="input_kms_alias_name"></a> [kms\_alias\_name](#input\_kms\_alias\_name) | The name of the KMS key that is used for S3 storage backend encryption. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_asg_name"></a> [asg\_name](#output\_asg\_name) | Name of the Vault autoscaling group |
| <a name="output_cluster_size"></a> [cluster\_size](#output\_cluster\_size) | Number of Vault nodes |
| <a name="output_launch_config_name"></a> [launch\_config\_name](#output\_launch\_config\_name) | Name of the Vault launch configuration |
| <a name="output_iam_role_arn"></a> [iam\_role\_arn](#output\_iam\_role\_arn) | ARN of the IAM role attached to the Vault instance. |
| <a name="output_iam_role_id"></a> [iam\_role\_id](#output\_iam\_role\_id) | ID of the IAM role attached to the Vault instance. |
| <a name="output_iam_role_name"></a> [iam\_role\_name](#output\_iam\_role\_name) | Name of the IAM role attached to the Vault instance. |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | Security group ID to attach to other security group rules as destination. |
| <a name="output_s3_bucket_arn"></a> [s3\_bucket\_arn](#output\_s3\_bucket\_arn) | ARN of the S3 bucket if used as storage backend |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

[1]: https://github.com/hashicorp/terraform-aws-vault/tree/master/modules/vault-cluster
[2]: https://github.com/hashicorp/terraform-aws-vault/issues/107
[3]: https://www.consul.io/docs/install/ports#ports-table
