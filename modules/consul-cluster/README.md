# Consul Cluster

This module was inspired by the following repository: [terraform-aws-vault][1].

## Caveats

### Security Groups

See this [GitHub issue][2], for clarifying the purpose of the SGs and their
rules.

[Here][3] are the ports in use and their purpose.

## Inputs

See all required rules [here][2].

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| vpc_id | The ID of the VPC in which to deploy the Consul cluster | string | - | yes |
| subnet_ids | The subnet IDs into which the EC2 Instances should be deployed. We recommend one subnet ID per node in the cluster_size variable. At least one of var.subnet_ids or var.availability_zones must be non-empty. | list | - | yes |
| ami_id | The ID of the AMI to run in this cluster. Should be an AMI that had Consul installed and configured by the install-consul module. | string | - | yes |
| user_data | A User Data script to execute while the server is booting. We remmend passing in a bash script that executes the run-consul script, which should have been installed in the Consul AMI by the install-consul module. | string | - | yes |
| instance_type | The type of EC2 Instances to run for each node in the cluster (e.g. t2.micro). | string | - | yes |
| cluster_size | The number of nodes to have in the Consul cluster. We strongly recommended that you use either 3 or 5. | string | `3` | no |
| tenancy | The tenancy of the instance. Must be one of: empty string, default or dedicated. For EC2 Spot Instances only empty string or dedicated can be used. | string | `` | no |
| root_volume_ebs_optimized | If true, the launched EC2 instance will be EBS-optimized. | string | `false` | no |
| root_volume_type | The type of volume. Must be one of: standard, gp2, or io1. | string | `standard` | no |
| root_volume_size | The size, in GB, of the root EBS volume. | string | `50` | no |
| root_volume_delete_on_termination | Whether the volume should be destroyed on instance termination. | string | `true` | no |
| termination_policies | A list of policies to decide how the instances in the auto scale group should be terminated. The allowed values are OldestInstance, NewestInstance, OldestLaunchConfiguration, ClosestToNextInstanceHour, Default. | string | `Default` | no |
| wait_for_capacity_timeout | A maximum duration that Terraform should wait for ASG instances to be healthy before timing out. Setting this to '0' causes Terraform to skip all Capacity Waiting behavior. | string | `10m` | no |
| health_check_type | Controls how health checking is done. Must be one of EC2 or ELB. | string | `EC2` | no |
| health_check_grace_period | Time, in seconds, after instance comes into service before checking health. | string | `60` | no |
| instance_profile_path | Path in which to create the IAM instance profile. | string | `/` | no |
| ssh_security_group_id | ID of the security group of a bastion ssh instance from where you can ssh into the Consul instances. | string | - | yes |
| vault_security_group_id | ID of the security group of the Vault instances to allow traffic from Vault into Consul. | string | - | yes |
| cluster_name | The name of the Consul cluster (e.g. consul-stage). This variable is used to namespace all resources created by this module. | string | - | yes |
| tags | Tags to attach to all AWS resources | map | `<map>` | no |
| cluster_tag_key | Add a tag with this key and the value var.cluster_tag_value to each Instance in the ASG. This can be used to automatically find other Consul nodes and form a cluster. | string | `consul-servers` | no |
| cluster_tag_value | Add a tag with key var.clsuter_tag_key and this value to each Instance in the ASG. This can be used to automatically find other Consul nodes and form a cluster. | string | `auto-join` | no |

## Outputs

| Name | Description |
|------|-------------|
| asg_name | Name of the Consul autoscaling group |
| cluster_size | Number of Consul nodes |
| launch_config_name | Name of the Consul launch configuration |
| iam_role_arn | ARN of the IAM role attached to the Consul instance. |
| iam_role_id | ID of the IAM role attached to the Consul instance. |
| iam_role_name | Name of the IAM role attached to the Consul instance. |
| security_group_id | Security group ID to attach to other security group rules as destination. |

[1]: https://github.com/hashicorp/terraform-aws-consul/tree/master/modules/consul-cluster
[2]: https://github.com/hashicorp/terraform-aws-vault/issues/107
[3]: https://www.consul.io/docs/install/ports#ports-table
