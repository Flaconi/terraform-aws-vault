# Custom VPC with HashiCorp Vault

This example deploys a custom VPC with a bastion host behind an ELB (including a Route53 DNS record)
and a Vault cluster behind an ELB (including a Route53 DNS record).

Custom SSH keys can be specified for each of the EC2 instances.

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example may create resources which can cost money (AWS Elastic IP, for example). Run terraform destroy when you don't need these resources.


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| region | The AWS region this module is strictly bound to. | string | - | yes |
| allowed_account_ids | The AWS account id to which this project is strictly bound. | list | - | yes |
| bastion_ingress_cidr_ssh | List of CIDR's from which you are allowed to ssh into the bastion host. | list | - | yes |
| vault_ingress_cidr_https | List of CIDR's from which you are allowed to https access the vault cluster. | list | - | yes |
| vpc_cidr | The VPC CIDR to use for this VPC. | string | - | yes |
| vpc_subnet_azs | A list of AZ's to use to spawn subnets over | list | - | yes |
| vpc_private_subnets | A list of private subnet CIDR's | list | - | yes |
| vpc_public_subnets | A list of public subnet CIDR's | list | - | yes |
| vpc_enable_nat_gateway | A boolean that enables or disables NAT gateways for private subnets | string | - | yes |
| vpc_enable_vpn_gateway | A boolean that enables or disables a VPN gateways for the VPC | string | - | yes |
| name | The name(-prefix) tag to apply to all AWS resources | string | `vault` | no |
| tags | A map of additional tags to apply to all AWS resources | map | `<map>` | no |
| vpc_tags | A map of additional tags to apply to the VPC | map | `<map>` | no |
| public_subnet_tags | A map of additional tags to apply to all public subnets | map | `<map>` | no |
| private_subnet_tags | A map of additional tags to apply to all private subnets | map | `<map>` | no |
| bastion_cluster_name | What to name the Bastion cluster and all of its associated resources | string | `vault-bastion` | no |
| consul_cluster_name | What to name the Consul server cluster and all of its associated resources | string | `vault-consul` | no |
| vault_cluster_name | What to name the Vault server cluster and all of its associated resources | string | `vault-vault` | no |
| bastion_route53_public_dns_name | The Route53 public DNS name for the vault ELB. If not set, no Route53 record will be created. | string | `` | no |
| vault_route53_public_dns_name | The Route53 public DNS name for the vault ELB. If not set, no Route53 record will be created. | string | `` | no |
| ssh_keys | A list of public ssh keys to add to authorized_keys files. | list | - | yes |
| bastion_instance_type | The type of EC2 Instance to run in the Bastion ASG | string | `t2.micro` | no |
| consul_instance_type | The type of EC2 Instance to run in the Consul ASG | string | `t2.micro` | no |
| vault_instance_type | The type of EC2 Instance to run in the Vault ASG | string | `t2.micro` | no |
| bastion_cluster_size | The number of Bastion nodes to deploy. | string | `1` | no |
| consul_cluster_size | The number of Consul server nodes to deploy. We strongly recommend using 3 or 5. | string | `3` | no |
| vault_cluster_size | The number of Vault server nodes to deploy. We strongly recommend using 3 or 5. | string | `3` | no |

## Outputs

| Name | Description |
|------|-------------|
| elb_fqdn_bastion | AWS generated CNAME for the bastion host ELB |
| elb_fqdn_vault | AWS generated CNAME for the vault ELB |
| elb_route53_public_dns_name_bastion | Route53 public DNS name for the bastion host ELB |
| elb_route53_public_dns_name_vault | Route53 public DNS name for the vault ELB |

