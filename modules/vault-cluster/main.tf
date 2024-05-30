resource "aws_autoscaling_group" "autoscaling_group" {
  name_prefix = var.cluster_name

  launch_template {
    id      = aws_launch_template.launch_template.id
    version = aws_launch_template.launch_template.latest_version
  }

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

# Launch Template Resource
resource "aws_launch_template" "launch_template" {
  name_prefix   = "${var.cluster_name}-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  user_data     = var.user_data

  iam_instance_profile {
    name = aws_iam_instance_profile.instance_profile.name
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

  ebs_optimized = var.root_volume_ebs_optimized
  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size = var.root_volume_size
      delete_on_termination = var.root_volume_delete_on_termination
      volume_type           = var.root_volume_type
    }
  }
}