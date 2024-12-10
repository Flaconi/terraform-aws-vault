module "vault_cluster" {
  source = "./modules/vault-cluster"

  cluster_name  = var.vault_cluster_name
  cluster_size  = var.vault_cluster_size
  instance_type = var.vault_instance_type

  ami_id = var.ami_id
  user_data = base64encode(templatefile("${path.module}/user-data/vault.sh.tftpl", {
    enable_s3_backend        = var.enable_s3_backend ? 1 : 0
    s3_bucket_region         = data.aws_region.current.name
    s3_bucket_name           = var.s3_bucket_name
    consul_cluster_tag_key   = local.consul_cluster_tag_key
    consul_cluster_tag_value = local.consul_cluster_tag_val
    ssh_keys                 = join("\n", var.ssh_keys)
    ssh_user                 = var.ssh_user
  }))

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  enable_s3_backend = var.enable_s3_backend
  s3_bucket_name    = var.s3_bucket_name

  enable_s3_backend_encryption = var.enable_s3_backend_encryption
  kms_alias_name               = var.kms_alias_name

  health_check_type = "EC2"

  elb_security_group_id    = module.vault_elb.security_group_ids[0]
  consul_security_group_id = module.consul_cluster.security_group_id
  ssh_security_group_id    = var.ssh_security_group_id

  tags = var.tags
}

module "consul_iam_policies_servers" {
  source = "github.com/hashicorp/terraform-aws-consul//modules/consul-iam-policies?ref=v0.11.0"

  iam_role_id = module.vault_cluster.iam_role_id
}

module "vault_elb" {
  source = "github.com/Flaconi/terraform-aws-elb?ref=v2.0.0"

  name       = var.vault_cluster_name
  vpc_id     = var.vpc_id
  subnet_ids = var.public_subnet_ids

  lb_port            = 443
  lb_protocol        = "HTTPS"
  instance_port      = 8200
  instance_protocol  = "HTTPS"
  ssl_certificate_id = var.ssl_certificate_id

  target              = "HTTPS:8200/v1/sys/health?standbyok=true"
  timeout             = 5
  interval            = 15
  healthy_threshold   = 2
  unhealthy_threshold = 2

  inbound_cidr_blocks  = var.vault_ingress_cidr_https
  security_group_names = var.security_group_names

  route53_public_dns_name = var.vault_route53_public_dns_name

  public_dns_evaluate_target_health = false

  tags = var.tags
}

resource "aws_autoscaling_attachment" "vault" {
  autoscaling_group_name = module.vault_cluster.asg_name
  elb                    = module.vault_elb.id
}

module "consul_cluster" {
  source = "./modules/consul-cluster"

  cluster_name  = var.consul_cluster_name
  cluster_size  = var.consul_cluster_size
  instance_type = var.consul_instance_type

  ami_id = var.ami_id
  user_data = base64encode(templatefile("${path.module}/user-data/consul.sh.tftpl", {
    consul_cluster_tag_key   = local.consul_cluster_tag_key
    consul_cluster_tag_value = local.consul_cluster_tag_val
    ssh_keys                 = join("\n", var.ssh_keys)
    ssh_user                 = var.ssh_user
  }))

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  vault_security_group_id = module.vault_cluster.security_group_id
  ssh_security_group_id   = var.ssh_security_group_id

  cluster_tag_key   = local.consul_cluster_tag_key
  cluster_tag_value = local.consul_cluster_tag_val

  tags = var.tags
}
