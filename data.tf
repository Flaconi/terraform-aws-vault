data "aws_region" "current" {}

data "aws_route53_zone" "public" {
  count = var.vault_route53_public_dns_name != "" ? 1 : 0

  private_zone = false

  # Removes the first sub-domain part from the FQDN to use as hosted zone.
  name = "${replace(var.vault_route53_public_dns_name, "/^.+?\\./", "")}."
}

data "aws_route53_zone" "private" {
  count = var.vault_route53_private_dns_name != "" ? 1 : 0

  private_zone = true

  # Removes the first sub-domain part from the FQDN to use as hosted zone.
  name = "${replace(var.vault_route53_private_dns_name, "/^.+?\\./", "")}."
}

data "aws_security_groups" "alb" {
  filter {
    name   = "group-name"
    values = var.security_group_names
  }
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}
