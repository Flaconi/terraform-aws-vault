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


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
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
