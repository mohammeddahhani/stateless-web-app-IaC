# Load balancer Security Group (external to ALB)
resource "aws_security_group" "alb-web-sg" {
  name        = "applicative_load_balancer_security_group"
  description = "ALB access control"
  vpc_id      = aws_vpc.main-vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }  

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance Security group
# ALB to web EC2 and SSH to jumpstation
resource "aws_security_group" "ec2-sg" {
  name        = "ec2_security_group"
  description = "Allows inbound access from the ALB and SSH access from outside"
  vpc_id      = aws_vpc.main-vpc.id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.alb-web-sg.id]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.ec2-jump-sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# Jumpstation Security Group
resource "aws_security_group" "ec2-jump-sg" {
  name        = "ec2_jumpstation_security_group"
  description = "SSH access to web EC2s"
  vpc_id      = aws_vpc.main-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]  # Allow SSH to private subnets
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
