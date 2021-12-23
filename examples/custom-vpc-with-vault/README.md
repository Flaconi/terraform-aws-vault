# Custom VPC with HashiCorp Vault

This example deploys a custom VPC with a bastion host behind an ELB and a Vault cluster behind an
ELB.

Custom SSH keys can be specified for each of the EC2 instances.

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example may create resources which can cost money (AWS Elastic IP, for example). Run terraform destroy when you don't need these resources.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12.26 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws_vpc"></a> [aws\_vpc](#module\_aws\_vpc) | github.com/Flaconi/terraform-modules-vpc | v2.1.0 |
| <a name="module_aws_vault"></a> [aws\_vault](#module\_aws\_vault) | ../.. | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | The name(-prefix) tag to apply to all AWS resources | `string` | `"vault"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of additional tags to apply to all AWS resources | `map(string)` | `{}` | no |
| <a name="input_vpc_tags"></a> [vpc\_tags](#input\_vpc\_tags) | A map of additional tags to apply to the VPC | `map(string)` | `{}` | no |
| <a name="input_public_subnet_tags"></a> [public\_subnet\_tags](#input\_public\_subnet\_tags) | A map of additional tags to apply to all public subnets | `map(string)` | <pre>{<br>  "Visibility": "public"<br>}</pre> | no |
| <a name="input_private_subnet_tags"></a> [private\_subnet\_tags](#input\_private\_subnet\_tags) | A map of additional tags to apply to all private subnets | `map(string)` | <pre>{<br>  "Visibility": "private"<br>}</pre> | no |
| <a name="input_bastion_cluster_name"></a> [bastion\_cluster\_name](#input\_bastion\_cluster\_name) | What to name the Bastion cluster and all of its associated resources | `string` | `"vault-bastion"` | no |
| <a name="input_consul_cluster_name"></a> [consul\_cluster\_name](#input\_consul\_cluster\_name) | What to name the Consul server cluster and all of its associated resources | `string` | `"vault-consul"` | no |
| <a name="input_vault_cluster_name"></a> [vault\_cluster\_name](#input\_vault\_cluster\_name) | What to name the Vault server cluster and all of its associated resources | `string` | `"vault-vault"` | no |
| <a name="input_bastion_route53_public_dns_name"></a> [bastion\_route53\_public\_dns\_name](#input\_bastion\_route53\_public\_dns\_name) | The Route53 public DNS name for the vault ELB. If not set, no Route53 record will be created. | `string` | `""` | no |
| <a name="input_vault_route53_public_dns_name"></a> [vault\_route53\_public\_dns\_name](#input\_vault\_route53\_public\_dns\_name) | The Route53 public DNS name for the vault ELB. If not set, no Route53 record will be created. | `string` | `""` | no |
| <a name="input_bastion_instance_type"></a> [bastion\_instance\_type](#input\_bastion\_instance\_type) | The type of EC2 Instance to run in the Bastion ASG | `string` | `"t2.micro"` | no |
| <a name="input_consul_instance_type"></a> [consul\_instance\_type](#input\_consul\_instance\_type) | The type of EC2 Instance to run in the Consul ASG | `string` | `"t2.micro"` | no |
| <a name="input_vault_instance_type"></a> [vault\_instance\_type](#input\_vault\_instance\_type) | The type of EC2 Instance to run in the Vault ASG | `string` | `"t2.micro"` | no |
| <a name="input_bastion_cluster_size"></a> [bastion\_cluster\_size](#input\_bastion\_cluster\_size) | The number of Bastion nodes to deploy. | `number` | `1` | no |
| <a name="input_consul_cluster_size"></a> [consul\_cluster\_size](#input\_consul\_cluster\_size) | The number of Consul server nodes to deploy. We strongly recommend using 3 or 5. | `number` | `3` | no |
| <a name="input_vault_cluster_size"></a> [vault\_cluster\_size](#input\_vault\_cluster\_size) | The number of Vault server nodes to deploy. We strongly recommend using 3 or 5. | `number` | `3` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_elb_fqdn_bastion"></a> [elb\_fqdn\_bastion](#output\_elb\_fqdn\_bastion) | AWS generated CNAME for the bastion host ELB |
| <a name="output_elb_fqdn_vault"></a> [elb\_fqdn\_vault](#output\_elb\_fqdn\_vault) | AWS generated CNAME for the vault ELB |
| <a name="output_elb_route53_public_dns_name_bastion"></a> [elb\_route53\_public\_dns\_name\_bastion](#output\_elb\_route53\_public\_dns\_name\_bastion) | Route53 public DNS name for the bastion host ELB |
| <a name="output_elb_route53_public_dns_name_vault"></a> [elb\_route53\_public\_dns\_name\_vault](#output\_elb\_route53\_public\_dns\_name\_vault) | Route53 public DNS name for the vault ELB |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
