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
    pushgateway_urls         = join(" ", var.pushgateway_urls)
  }))

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  enable_s3_backend = var.enable_s3_backend
  s3_bucket_name    = var.s3_bucket_name

  enable_s3_backend_encryption = var.enable_s3_backend_encryption
  kms_alias_name               = var.kms_alias_name

  health_check_type = "EC2"

  alb_security_group_id    = module.vault_alb.security_group_id
  consul_security_group_id = module.consul_cluster.security_group_id
  ssh_security_group_id    = var.ssh_security_group_id

  tags = var.tags
}

module "consul_iam_policies_servers" {
  source = "github.com/hashicorp/terraform-aws-consul//modules/consul-iam-policies?ref=v0.11.0"

  iam_role_id = module.vault_cluster.iam_role_id
}

module "vault_alb" {
  source = "github.com/terraform-aws-modules/terraform-aws-alb?ref=v9.12.0"

  name    = var.vault_cluster_name
  vpc_id  = var.vpc_id
  subnets = var.public_subnet_ids

  security_group_name        = "${var.name}-alb"
  security_group_description = "ALB security group for external connection"
  security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      cidr_ipv4   = var.vault_ingress_cidr
      description = "HTTP web traffic"
    }
    all_https = {
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      cidr_ipv4   = var.vault_ingress_cidr
      description = "HTTPS web traffic"
    }
  }
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
      description = "AWS default egress rule"
    }
  }
  security_groups = data.aws_security_groups.alb.ids

  # new
  listeners = {
    http-https-redirect = {
      port     = 80
      protocol = "HTTP"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
    https = {
      port            = 443
      protocol        = "HTTPS"
      ssl_policy      = "ELBSecurityPolicy-TLS13-1-3-2021-06"
      certificate_arn = var.ssl_certificate_id

      forward = {
        target_group_key = "vault"
      }
    }
  }

  target_groups = {
    vault = {
      name_prefix = "vault"
      protocol    = "HTTPS"
      port        = 8200

      create_attachment = false

      health_check = {
        enable              = true
        path                = "/v1/sys/health?standbyok=true"
        port                = "traffic-port"
        protocol            = "HTTPS"
        timeout             = 5
        interval            = 15
        healthy_threshold   = 2
        unhealthy_threshold = 2
      }
    }
  }

  # Route53 Record(s)
  route53_records = merge(
    var.vault_route53_public_dns_name != "" ? {
      public = {
        name    = var.vault_route53_public_dns_name
        type    = "A"
        zone_id = data.aws_route53_zone.public[0].id
      }
    } : {},
    var.vault_route53_private_dns_name != "" ? {
      private = {
        name    = var.vault_route53_private_dns_name
        type    = "A"
        zone_id = data.aws_route53_zone.private[0].id
      }
    } : {}
  )

  tags = var.tags
}

resource "aws_autoscaling_attachment" "vault" {
  autoscaling_group_name = module.vault_cluster.asg_name
  lb_target_group_arn    = module.vault_alb.target_groups["vault"].arn
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
