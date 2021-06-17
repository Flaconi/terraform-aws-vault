# -------------------------------------------------------------------------------------------------
# ELB
# -------------------------------------------------------------------------------------------------
output "elb_fqdn_bastion" {
  value       = module.aws_vpc.bastion_elb_fqdn
  description = "AWS generated CNAME for the bastion host ELB"
}

output "elb_fqdn_vault" {
  value       = module.aws_vault.elb_fqdn_vault
  description = "AWS generated CNAME for the vault ELB"
}

output "elb_route53_public_dns_name_bastion" {
  value       = module.aws_vpc.bastion_route53_public_dns_name
  description = "Route53 public DNS name for the bastion host ELB"
}

output "elb_route53_public_dns_name_vault" {
  value       = module.aws_vault.elb_route53_public_dns_name_vault
  description = "Route53 public DNS name for the vault ELB"
}

