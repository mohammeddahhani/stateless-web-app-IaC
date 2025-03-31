
resource "aws_autoscaling_group" "ec2-cluster" {
  name                 = "auto_scaling_group"
  min_size             = var.autoscale_min
  max_size             = var.autoscale_max
  desired_capacity     = var.autoscale_desired
  health_check_type    = "EC2"
  vpc_zone_identifier  = values(aws_subnet.private)[*].id
  target_group_arns    = [aws_alb_target_group.https-target-group.arn]

  launch_template {
    id      = aws_launch_template.ec2.id
    version = "$Latest"
  }  
}
