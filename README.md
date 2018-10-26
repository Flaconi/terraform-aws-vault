# Terraform Module: HashiCorp Vault

[![Tag](https://img.shields.io/github/tag/Flaconi/terraform-aws-vault.svg)](https://github.com/Flaconi/terraform-aws-vault/releases)
[![License](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

This Terraform module provisions HashiCorp Vault with Consul Backend into an existing VPC including
an ELB with optionally a public Route53 DNS name fronting the Vault cluster.

## Usage example

```hcl
module "aws_vault" {
  source  = "github.com/Flaconi/terraform-aws-vault?ref=v0.1.0"

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

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| vpc_id | The VPC ID into which you want to provision Vault. | string | - | yes |
| public_subnet_ids | A list of public subnet IDs into which the Vault ELB will be provisioned. | list | - | yes |
| private_subnet_ids | A list of private subnet IDs into which Vault and Consul will be provisioned. | list | - | yes |
| name | The name(-prefix) tag to apply to all AWS resources | string | `vault` | no |
| tags | A map of additional tags to apply to all AWS resources | map | `<map>` | no |
| consul_cluster_name | What to name the Consul server cluster and all of its associated resources | string | `vault-consul` | no |
| vault_cluster_name | What to name the Vault server cluster and all of its associated resources | string | `vault-vault` | no |
| vault_route53_public_dns_name | The Route53 public DNS name for the vault ELB. If not set, no Route53 record will be created. | string | `` | no |
| ssh_keys | A list of public ssh keys to add to authorized_keys files. | list | - | yes |
| consul_instance_type | The type of EC2 Instance to run in the Consul ASG | string | `t2.micro` | no |
| vault_instance_type | The type of EC2 Instance to run in the Vault ASG | string | `t2.micro` | no |
| consul_cluster_size | The number of Consul server nodes to deploy. We strongly recommend using 3 or 5. | string | `3` | no |
| vault_cluster_size | The number of Vault server nodes to deploy. We strongly recommend using 3 or 5. | string | `3` | no |
| ssh_security_group_id | Security group ID of a bastion (or other EC2 instance) from which you will be allowed to ssh into Vault and Consul. | string | - | yes |
| vault_ingress_cidr_https | List of CIDR's from which you are allowed to https access the vault cluster. | list | `<list>` | no |

## Outputs

| Name | Description |
|------|-------------|
| elb_fqdn_vault | The AWS provided CNAME of the Vault ELB. |
| elb_route53_public_dns_name_vault | The Route53 name attached to the Vault ELB, if spcified in variables. |
| asg_name_consul_cluster | Autoscaling group name of the Consul cluster. |
| asg_name_vault_cluster | Autoscaling group name of the Vault cluster. |
| launch_config_name_consul_cluster | Launch configuration name of the Consul cluster. |
| launch_config_name_vault_cluster | Launch configuration name of the Vault cluster. |
| iam_role_arn_consul_cluster | IAM role ARN attached to the Consul cluster. |
| iam_role_arn_vault_cluster | IAM role ARN attached to the Vault cluster. |
| iam_role_id_consul_cluster | IAM role ID attached to the Consul cluster. |
| iam_role_id_vault_cluster | IAM role ID attached to the Vault cluster. |
| security_group_id_consul_cluster | Security group ID of the Consul cluster to attach to other security group rules. |
| security_group_id_vault_cluster | Security group ID of the Vault cluster to attach to other security group rules. |
| aws_region | Used AWS region. |

## License

[Apache 2.0](LICENSE)

Copyright (c) 2018 [Flaconi GmbH](https://github.com/Flaconi)
