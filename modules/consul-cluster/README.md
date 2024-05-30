# Consul Cluster

This module was inspired by the following repository: [terraform-aws-vault][1].

## Caveats

### Security Groups

See this [GitHub issue][2], for clarifying the purpose of the SGs and their
rules.

[Here][3] are the ports in use and their purpose.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5 |
| <a name="provider_null"></a> [null](#provider\_null) | >= 3 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_attach_security_group"></a> [attach\_security\_group](#module\_attach\_security\_group) | terraform-aws-modules/security-group/aws | 5.1.0 |
| <a name="module_iam_policies"></a> [iam\_policies](#module\_iam\_policies) | github.com/hashicorp/terraform-aws-consul//modules/consul-iam-policies | v0.11.0 |
| <a name="module_lc_security_group"></a> [lc\_security\_group](#module\_lc\_security\_group) | terraform-aws-modules/security-group/aws | 5.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_autoscaling_group.autoscaling_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_iam_instance_profile.instance_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.instance_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_launch_template.launch_template](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [null_resource.tags_as_list_of_maps](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [aws_iam_policy_document.instance_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami_id"></a> [ami\_id](#input\_ami\_id) | The ID of the AMI to run in this cluster. Should be an AMI that had Consul installed and configured by the install-consul module. | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of the Consul cluster (e.g. consul-stage). This variable is used to namespace all resources created by this module. | `string` | n/a | yes |
| <a name="input_cluster_size"></a> [cluster\_size](#input\_cluster\_size) | The number of nodes to have in the Consul cluster. We strongly recommended that you use either 3 or 5. | `number` | `3` | no |
| <a name="input_cluster_tag_key"></a> [cluster\_tag\_key](#input\_cluster\_tag\_key) | Add a tag with this key and the value var.cluster\_tag\_value to each Instance in the ASG. This can be used to automatically find other Consul nodes and form a cluster. | `string` | `"consul-servers"` | no |
| <a name="input_cluster_tag_value"></a> [cluster\_tag\_value](#input\_cluster\_tag\_value) | Add a tag with key var.clsuter\_tag\_key and this value to each Instance in the ASG. This can be used to automatically find other Consul nodes and form a cluster. | `string` | `"auto-join"` | no |
| <a name="input_health_check_grace_period"></a> [health\_check\_grace\_period](#input\_health\_check\_grace\_period) | Time, in seconds, after instance comes into service before checking health. | `number` | `60` | no |
| <a name="input_health_check_type"></a> [health\_check\_type](#input\_health\_check\_type) | Controls how health checking is done. Must be one of EC2 or ELB. | `string` | `"EC2"` | no |
| <a name="input_instance_profile_path"></a> [instance\_profile\_path](#input\_instance\_profile\_path) | Path in which to create the IAM instance profile. | `string` | `"/"` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | The type of EC2 Instances to run for each node in the cluster (e.g. t3.micro). | `string` | `"t3.micro"` | no |
| <a name="input_root_volume_delete_on_termination"></a> [root\_volume\_delete\_on\_termination](#input\_root\_volume\_delete\_on\_termination) | Whether the volume should be destroyed on instance termination. | `bool` | `true` | no |
| <a name="input_root_volume_ebs_optimized"></a> [root\_volume\_ebs\_optimized](#input\_root\_volume\_ebs\_optimized) | If true, the launched EC2 instance will be EBS-optimized. | `bool` | `false` | no |
| <a name="input_root_volume_size"></a> [root\_volume\_size](#input\_root\_volume\_size) | The size, in GB, of the root EBS volume. | `number` | `50` | no |
| <a name="input_root_volume_type"></a> [root\_volume\_type](#input\_root\_volume\_type) | The type of volume. Must be one of: standard, gp2, or io1. | `string` | `"standard"` | no |
| <a name="input_ssh_security_group_id"></a> [ssh\_security\_group\_id](#input\_ssh\_security\_group\_id) | ID of the security group of a bastion ssh instance from where you can ssh into the Consul instances. | `string` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | The subnet IDs into which the EC2 Instances should be deployed. We recommend one subnet ID per node in the cluster\_size variable. At least one of var.subnet\_ids or var.availability\_zones must be non-empty. | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to attach to all AWS resources | `map(string)` | `{}` | no |
| <a name="input_termination_policies"></a> [termination\_policies](#input\_termination\_policies) | A list of policies to decide how the instances in the auto scale group should be terminated. The allowed values are OldestInstance, NewestInstance, OldestLaunchConfiguration, ClosestToNextInstanceHour, Default. | `string` | `"Default"` | no |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | A User Data script to execute while the server is booting. We remmend passing in a bash script that executes the run-consul script, which should have been installed in the Consul AMI by the install-consul module. | `string` | n/a | yes |
| <a name="input_vault_security_group_id"></a> [vault\_security\_group\_id](#input\_vault\_security\_group\_id) | ID of the security group of the Vault instances to allow traffic from Vault into Consul. | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC in which to deploy the Consul cluster | `string` | n/a | yes |
| <a name="input_wait_for_capacity_timeout"></a> [wait\_for\_capacity\_timeout](#input\_wait\_for\_capacity\_timeout) | A maximum duration that Terraform should wait for ASG instances to be healthy before timing out. Setting this to '0' causes Terraform to skip all Capacity Waiting behavior. | `string` | `"10m"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_asg_name"></a> [asg\_name](#output\_asg\_name) | Name of the Consul autoscaling group |
| <a name="output_cluster_size"></a> [cluster\_size](#output\_cluster\_size) | Number of Consul nodes |
| <a name="output_iam_role_arn"></a> [iam\_role\_arn](#output\_iam\_role\_arn) | ARN of the IAM role attached to the Consul instance. |
| <a name="output_iam_role_id"></a> [iam\_role\_id](#output\_iam\_role\_id) | ID of the IAM role attached to the Consul instance. |
| <a name="output_iam_role_name"></a> [iam\_role\_name](#output\_iam\_role\_name) | Name of the IAM role attached to the Consul instance. |
| <a name="output_launch_template"></a> [launch\_template](#output\_launch\_template) | Name of the Vault launch\_template |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | Security group ID to attach to other security group rules as destination. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

[1]: https://github.com/hashicorp/terraform-aws-consul/tree/master/modules/consul-cluster
[2]: https://github.com/hashicorp/terraform-aws-vault/issues/107
[3]: https://www.consul.io/docs/install/ports#ports-table
