# Terraform Module: HashiCorp Vault

[![lint](https://github.com/flaconi/terraform-aws-vault/workflows/lint/badge.svg)](https://github.com/flaconi/terraform-aws-vault/actions?query=workflow%3Alint)
[![test](https://github.com/flaconi/terraform-aws-vault/workflows/test/badge.svg)](https://github.com/flaconi/terraform-aws-vault/actions?query=workflow%3Atest)
[![Tag](https://img.shields.io/github/tag/flaconi/terraform-aws-vault.svg)](https://github.com/flaconi/terraform-aws-vault/releases)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

This Terraform module provisions HashiCorp Vault with Consul Backend into an existing VPC including
an ELB with optionally a public Route53 DNS name fronting the Vault cluster.

## Usage example

```hcl
module "aws_vault" {
  source  = "github.com/Flaconi/terraform-aws-vault?ref=v2.1.0"

  # Placement
  vpc_id             = "vpc-1234"
  public_subnet_ids  = ["subnet-4321", "subnet-9876"]
  private_subnet_ids = ["subnet-1234", "subnet-5678"]

  # Resource Naming/Tagging
  name                = "vault"
  consul_cluster_name = "my-consul"
  vault_cluster_name  = "my-vault"

  # Security
  ssh_keys                 = ["ssh-ed25519 AAAAC3Nznte5aaCdi1a1Lzaai/tX6Mc2E+S6g3lrClL09iBZ5cW2OZdSIqomcMko 2 mysshkey"]
  ssh_security_group_id    = "sg-0c12345678"
  vault_ingress_cidr_https = ["0.0.0.0/0"]
}
```

## Examples

* [Custom VPC with HashiCorp Vault](examples/custom-vpc-with-vault)

<!-- TFDOCS_HEADER_START -->


<!-- TFDOCS_HEADER_END -->

<!-- TFDOCS_PROVIDER_START -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3 |
| <a name="provider_template"></a> [template](#provider\_template) | n/a |

<!-- TFDOCS_PROVIDER_END -->

<!-- TFDOCS_REQUIREMENTS_START -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12.26 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3 |

<!-- TFDOCS_REQUIREMENTS_END -->

<!-- TFDOCS_INPUTS_START -->
## Required Inputs

The following input variables are required:

### <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id)

Description: The VPC ID into which you want to provision Vault.

Type: `string`

### <a name="input_public_subnet_ids"></a> [public\_subnet\_ids](#input\_public\_subnet\_ids)

Description: A list of public subnet IDs into which the Vault ELB will be provisioned.

Type: `list(string)`

### <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids)

Description: A list of private subnet IDs into which Vault and Consul will be provisioned.

Type: `list(string)`

### <a name="input_ssh_keys"></a> [ssh\_keys](#input\_ssh\_keys)

Description: A list of public ssh keys to add to authorized\_keys files.

Type: `list(string)`

### <a name="input_ssh_security_group_id"></a> [ssh\_security\_group\_id](#input\_ssh\_security\_group\_id)

Description: Security group ID of a bastion (or other EC2 instance) from which you will be allowed to ssh into Vault and Consul.

Type: `string`

### <a name="input_ssl_certificate_id"></a> [ssl\_certificate\_id](#input\_ssl\_certificate\_id)

Description: ARN of the certificate to be used for the Vault endpoint ELB

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_name"></a> [name](#input\_name)

Description: The name(-prefix) tag to apply to all AWS resources

Type: `string`

Default: `"vault"`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: A map of additional tags to apply to all AWS resources

Type: `map(string)`

Default: `{}`

### <a name="input_consul_cluster_name"></a> [consul\_cluster\_name](#input\_consul\_cluster\_name)

Description: What to name the Consul server cluster and all of its associated resources

Type: `string`

Default: `"vault-consul"`

### <a name="input_vault_cluster_name"></a> [vault\_cluster\_name](#input\_vault\_cluster\_name)

Description: What to name the Vault server cluster and all of its associated resources

Type: `string`

Default: `"vault-vault"`

### <a name="input_vault_route53_public_dns_name"></a> [vault\_route53\_public\_dns\_name](#input\_vault\_route53\_public\_dns\_name)

Description: The Route53 public DNS name for the vault ELB. If not set, no Route53 record will be created.

Type: `string`

Default: `""`

### <a name="input_consul_instance_type"></a> [consul\_instance\_type](#input\_consul\_instance\_type)

Description: The type of EC2 Instance to run in the Consul ASG

Type: `string`

Default: `"t3.micro"`

### <a name="input_vault_instance_type"></a> [vault\_instance\_type](#input\_vault\_instance\_type)

Description: The type of EC2 Instance to run in the Vault ASG

Type: `string`

Default: `"t3.micro"`

### <a name="input_consul_cluster_size"></a> [consul\_cluster\_size](#input\_consul\_cluster\_size)

Description: The number of Consul server nodes to deploy. We strongly recommend using 3 or 5.

Type: `number`

Default: `3`

### <a name="input_vault_cluster_size"></a> [vault\_cluster\_size](#input\_vault\_cluster\_size)

Description: The number of Vault server nodes to deploy. We strongly recommend using 3 or 5.

Type: `number`

Default: `3`

### <a name="input_vault_ingress_cidr_https"></a> [vault\_ingress\_cidr\_https](#input\_vault\_ingress\_cidr\_https)

Description: List of CIDR's from which you are allowed to https access the vault cluster.

Type: `list(string)`

Default:

```json
[
  "0.0.0.0/0"
]
```

### <a name="input_security_group_names"></a> [security\_group\_names](#input\_security\_group\_names)

Description: List of one or more security groups to be added to the load balancer

Type: `list(string)`

Default: `[]`

### <a name="input_enable_s3_backend"></a> [enable\_s3\_backend](#input\_enable\_s3\_backend)

Description: Whether to configure an S3 storage backend in the same region in addition to Consul.

Type: `bool`

Default: `false`

### <a name="input_s3_bucket_name"></a> [s3\_bucket\_name](#input\_s3\_bucket\_name)

Description: The name of the S3 bucket in the same region to use as a storage backend. Only used if 'enable\_s3\_backend' is set to true.

Type: `string`

Default: `""`

### <a name="input_enable_s3_backend_encryption"></a> [enable\_s3\_backend\_encryption](#input\_enable\_s3\_backend\_encryption)

Description: Whether to configure the S3 storage backend to be encrypted with a KMS key.

Type: `bool`

Default: `false`

### <a name="input_kms_alias_name"></a> [kms\_alias\_name](#input\_kms\_alias\_name)

Description: The name of the KMS key that is used for S3 storage backend encryption.

Type: `string`

Default: `""`

### <a name="input_ami_name_filter"></a> [ami\_name\_filter](#input\_ami\_name\_filter)

Description: Name filter to help pick the AMI.

Type: `list(string)`

Default:

```json
[
  "vault-consul-ubuntu-*"
]
```

### <a name="input_ami_id"></a> [ami\_id](#input\_ami\_id)

Description: ID of the AMI to be used for the Consul and Vault instances.

Type: `string`

Default: `""`

### <a name="input_ami_owner"></a> [ami\_owner](#input\_ami\_owner)

Description: AWS account ID of the AMI owner. Defaults to HashiCorp.

Type: `string`

Default: `"562637147889"`

<!-- TFDOCS_INPUTS_END -->

<!-- TFDOCS_OUTPUTS_START -->
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_asg_name_consul_cluster"></a> [asg\_name\_consul\_cluster](#output\_asg\_name\_consul\_cluster) | Autoscaling group name of the Consul cluster. |
| <a name="output_asg_name_vault_cluster"></a> [asg\_name\_vault\_cluster](#output\_asg\_name\_vault\_cluster) | Autoscaling group name of the Vault cluster. |
| <a name="output_aws_region"></a> [aws\_region](#output\_aws\_region) | Used AWS region. |
| <a name="output_elb_fqdn_vault"></a> [elb\_fqdn\_vault](#output\_elb\_fqdn\_vault) | The AWS provided CNAME of the Vault ELB. |
| <a name="output_elb_route53_public_dns_name_vault"></a> [elb\_route53\_public\_dns\_name\_vault](#output\_elb\_route53\_public\_dns\_name\_vault) | The Route53 name attached to the Vault ELB, if spcified in variables. |
| <a name="output_iam_role_arn_consul_cluster"></a> [iam\_role\_arn\_consul\_cluster](#output\_iam\_role\_arn\_consul\_cluster) | IAM role ARN attached to the Consul cluster. |
| <a name="output_iam_role_arn_vault_cluster"></a> [iam\_role\_arn\_vault\_cluster](#output\_iam\_role\_arn\_vault\_cluster) | IAM role ARN attached to the Vault cluster. |
| <a name="output_iam_role_id_consul_cluster"></a> [iam\_role\_id\_consul\_cluster](#output\_iam\_role\_id\_consul\_cluster) | IAM role ID attached to the Consul cluster. |
| <a name="output_iam_role_id_vault_cluster"></a> [iam\_role\_id\_vault\_cluster](#output\_iam\_role\_id\_vault\_cluster) | IAM role ID attached to the Vault cluster. |
| <a name="output_launch_config_name_consul_cluster"></a> [launch\_config\_name\_consul\_cluster](#output\_launch\_config\_name\_consul\_cluster) | Launch configuration name of the Consul cluster. |
| <a name="output_launch_config_name_vault_cluster"></a> [launch\_config\_name\_vault\_cluster](#output\_launch\_config\_name\_vault\_cluster) | Launch configuration name of the Vault cluster. |
| <a name="output_security_group_id_consul_cluster"></a> [security\_group\_id\_consul\_cluster](#output\_security\_group\_id\_consul\_cluster) | Security group ID of the Consul cluster to attach to other security group rules. |
| <a name="output_security_group_id_vault_cluster"></a> [security\_group\_id\_vault\_cluster](#output\_security\_group\_id\_vault\_cluster) | Security group ID of the Vault cluster to attach to other security group rules. |

<!-- TFDOCS_OUTPUTS_END -->

## License

[Apache 2.0](LICENSE)

Copyright (c) 2018-2021 [Flaconi GmbH](https://github.com/Flaconi)
