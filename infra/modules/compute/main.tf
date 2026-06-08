data "aws_iam_policy_document" "ssm_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ssm" {
  name               = "${var.project}-ssm-${var.env}"
  assume_role_policy = data.aws_iam_policy_document.ssm_assume.json
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm" {
  name = "${var.project}-ssm-profile-${var.env}"
  role = aws_iam_role.ssm.name
}

resource "aws_launch_template" "app" {
  name_prefix   = "${var.project}-compute-"
  image_id      = var.ami_id
  instance_type = var.instance_type

  iam_instance_profile {
    name = aws_iam_instance_profile.ssm.name
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [var.security_group_id]
  }

  user_data = base64encode(templatefile("${path.module}/userdata.sh", {
    database_url        = var.database_url
    redis_url           = var.redis_url
    secret_key          = var.secret_key
    smtp_user           = var.smtp_user
    smtp_pass           = var.smtp_pass
    razorpay_key_id     = var.razorpay_key_id
    razorpay_key_secret = var.razorpay_key_secret
    frontend_url        = var.frontend_url
    backend_url         = var.backend_url
    repo_url            = var.repo_url
    environment         = var.env
  }))

  tag_specifications {
    resource_type = "instance"
    tags          = { Name = "${var.project}-${var.env}" }
  }
}

resource "aws_autoscaling_group" "app" {
  name                      = "${var.project}-asg-${var.env}"
  desired_capacity          = var.asg_desired
  min_size                  = var.asg_min
  max_size                  = var.asg_max
  vpc_zone_identifier       = var.subnet_ids
  health_check_type         = "ELB"
  health_check_grace_period = 180
  target_group_arns         = [var.target_group_arn]

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }
}

resource "aws_autoscaling_policy" "scale_up" {
  name                   = "${var.project}-scale-up-${var.env}"
  autoscaling_group_name = aws_autoscaling_group.app.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 300
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${var.project}-cpu-high-${var.env}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 70
  alarm_actions       = [aws_autoscaling_policy.scale_up.arn]
  dimensions          = { AutoScalingGroupName = aws_autoscaling_group.app.name }
}

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "${var.project}-scale-down-${var.env}"
  autoscaling_group_name = aws_autoscaling_group.app.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 300
}

resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "${var.project}-cpu-low-${var.env}"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 3
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 30
  alarm_actions       = [aws_autoscaling_policy.scale_down.arn]
  dimensions          = { AutoScalingGroupName = aws_autoscaling_group.app.name }
}

resource "aws_cloudwatch_log_group" "app" {
  name              = "/${var.project}/${var.env}"
  retention_in_days = var.env == "prod" ? 14 : 7
}
