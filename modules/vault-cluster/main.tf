resource "aws_autoscaling_group" "autoscaling_group" {
  name_prefix = var.cluster_name

  launch_configuration = aws_launch_configuration.launch_configuration.name

  vpc_zone_identifier = flatten(var.subnet_ids)

  min_size             = var.cluster_size
  max_size             = var.cluster_size
  desired_capacity     = var.cluster_size
  termination_policies = [var.termination_policies]

  health_check_type         = var.health_check_type
  health_check_grace_period = var.health_check_grace_period
  wait_for_capacity_timeout = var.wait_for_capacity_timeout

  tags = concat(
    [
      {
        "key"                 = "Name"
        "value"               = var.cluster_name
        "propagate_at_launch" = true
      }
    ],
    local.tags_asg_format,
  )

  lifecycle {
    ignore_changes = [
      load_balancers,
    ]
  }
}

resource "aws_launch_configuration" "launch_configuration" {
  name_prefix   = "${var.cluster_name}-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  user_data     = var.user_data

  iam_instance_profile = aws_iam_instance_profile.instance_profile.name
  placement_tenancy    = var.tenancy

  ebs_optimized = var.root_volume_ebs_optimized
  root_block_device {
    volume_type           = var.root_volume_type
    volume_size           = var.root_volume_size
    delete_on_termination = var.root_volume_delete_on_termination
  }

  lifecycle {
    create_before_destroy = true
  }
}
