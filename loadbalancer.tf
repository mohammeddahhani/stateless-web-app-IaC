# Load Balancer
resource "aws_lb" "main-alb" {
  name               = "web-alb"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.alb-web-sg.id]
  subnets            = values(aws_subnet.public)[*].id
}

# HTTP Target group
resource "aws_alb_target_group" "http-target-group" {
  name     = "http-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main-vpc.id

  health_check {
    path                = var.health_check_path
    port                = "traffic-port"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 2
    interval            = 60
    matcher             = "200"
  }
}


# HTTP Listener redirecting to HTTPS (security measures)
resource "aws_alb_listener" "ec2-alb-http-listener" {
  load_balancer_arn = aws_lb.main-alb.id
  port              = "80"
  protocol          = "HTTP"
  depends_on        = [aws_alb_target_group.http-target-group]


  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# HTTPS Listener
resource "aws_alb_listener" "ec2-alb-https-listener" {
  load_balancer_arn = aws_lb.main-alb.id
  port              = "443"
  protocol          = "HTTPS"
  depends_on        = [aws_alb_target_group.http-target-group]

  ssl_policy = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.ssl_cert.arn


  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.http-target-group.arn 
   }
}

# link the EC2 clister to the target group of the loadbalancer
resource "aws_autoscaling_attachment" "asg_attachment_bar" {
  autoscaling_group_name = aws_autoscaling_group.ec2-cluster.id
  lb_target_group_arn    = aws_alb_target_group.http-target-group.arn
}
