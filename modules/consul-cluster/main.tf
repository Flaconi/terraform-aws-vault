resource "aws_autoscaling_group" "autoscaling_group" {
  name_prefix = var.cluster_name

  launch_template {
    id      = aws_launch_template.launch_configuration.id
    version = aws_launch_template.launch_configuration.latest_version
  }
  # launch_configuration = aws_launch_configuration.launch_configuration.name

  vpc_zone_identifier = flatten(var.subnet_ids)

  min_size             = var.cluster_size
  max_size             = var.cluster_size
  desired_capacity     = var.cluster_size
  termination_policies = [var.termination_policies]

  health_check_type         = var.health_check_type
  health_check_grace_period = var.health_check_grace_period
  wait_for_capacity_timeout = var.wait_for_capacity_timeout

  dynamic "tag" {
    for_each = concat(
      [
        {
          key                 = "Name"
          value               = var.cluster_name
          propagate_at_launch = true
        },
        {
          key                 = var.cluster_tag_key
          value               = var.cluster_tag_value
          propagate_at_launch = true
        }
      ],
      local.tags_asg_format,
    )
    content {
      key                 = tag.value["key"]
      value               = tag.value["value"]
      propagate_at_launch = tag.value["propagate_at_launch"]
    }
  }

  lifecycle {
    ignore_changes = [
      load_balancers,
    ]
  }
}

# resource "aws_launch_configuration" "launch_configuration" {
#   name_prefix   = "${var.cluster_name}-"
#   image_id      = var.ami_id
#   instance_type = var.instance_type
#   user_data     = var.user_data

#   iam_instance_profile = aws_iam_instance_profile.instance_profile.name
#   placement_tenancy    = var.tenancy

#   metadata_options {
#     http_tokens                 = "required"
#     http_put_response_hop_limit = 1
#     http_endpoint               = "enabled"
#   }

#   security_groups = [
#     module.lc_security_group.security_group_id,
#     module.attach_security_group.security_group_id,
#   ]

#   associate_public_ip_address = false

#   ebs_optimized = var.root_volume_ebs_optimized
#   root_block_device {
#     volume_type           = var.root_volume_type
#     volume_size           = var.root_volume_size
#     delete_on_termination = var.root_volume_delete_on_termination
#   }

#   lifecycle {
#     create_before_destroy = true
#   }
# }
resource "aws_launch_template" "launch_configuration" {
  name_prefix   = "${var.cluster_name}-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  user_data     = var.user_data

  iam_instance_profile {
    name = aws_iam_instance_profile.instance_profile.name
  }
  placement {
    tenancy = var.tenancy
  }

  vpc_security_group_ids = [
    module.lc_security_group.security_group_id,
    module.attach_security_group.security_group_id,
  ]
  metadata_options {
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    http_endpoint               = "enabled"
  }

  network_interfaces {
    associate_public_ip_address = false
  }

  ebs_optimized = var.root_volume_ebs_optimized
  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size = var.root_volume_size
      #volume_size = 20 # LT Update Testing - Version 2 of LT      
      delete_on_termination = var.root_volume_delete_on_termination
      volume_type           = var.root_volume_type
    }
  }
}