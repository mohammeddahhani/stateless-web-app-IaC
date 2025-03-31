data "aws_iam_policy_document" "ec2" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "session-manager" {
  description = "session-manager"
  name        = "session-manager"
  policy      = jsonencode({
    "Version":"2012-10-17",
    "Statement":[
      {
        "Action": "ec2:*",
        "Effect": "Allow",
        "Resource": "*"
      },
      {
          "Effect": "Allow",
          "Action": "elasticloadbalancing:*",
          "Resource": "*"
      },
      {
          "Effect": "Allow",
          "Action": "cloudwatch:*",
          "Resource": "*"
      },
      {
          "Effect": "Allow",
          "Action": "autoscaling:*",
          "Resource": "*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "acm:ImportCertificate",
          "acm:ListCertificates",
          "acm:DescribeCertificate"
        ],
        "Resource": "*"
      },      
      {
          "Effect": "Allow",
          "Action": "iam:CreateServiceLinkedRole",
          "Resource": "*",
          "Condition": {
              "StringEquals": {
                  "iam:AWSServiceName": [
                      "autoscaling.amazonaws.com",
                      "ec2scheduled.amazonaws.com",
                      "elasticloadbalancing.amazonaws.com",
                      "spot.amazonaws.com",
                      "spotfleet.amazonaws.com",
                      "transitgateway.amazonaws.com"
                  ]
              }
          }
      }
    ]
  })
}

resource "aws_iam_role" "session-manager" {
  assume_role_policy = data.aws_iam_policy_document.ec2.json
  name               = "session-manager"
  tags = {
    Name = "session-manager"
  }
}

resource "aws_iam_instance_profile" "session-manager" {
  name  = "session-manager"
  role  = aws_iam_role.session-manager.name
}

resource "aws_instance" "jumpstation" {
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = "${var.instance_type}"
  key_name                    = aws_key_pair.ssh-key.key_name
  iam_instance_profile        = aws_iam_instance_profile.session-manager.id
  associate_public_ip_address = true
  security_groups             = [aws_security_group.ec2-jump-sg.id]
  subnet_id                   = aws_subnet.public[keys(var.subnets["public"])[1]].id
  tags = {
    Name = "jumpstation"
  }
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file(var.key_path)  
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Hello, world!' > ~/trace"
    ]
  }

}


resource "aws_launch_template" "ec2" {
  name_prefix   = "launch-template"
  image_id      = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.ssh-key.key_name

  user_data     = base64encode(<<-EOF
  #!/bin/bash -xe
  sudo yum update -y
  sudo yum -y install docker
  sudo service docker start
  sudo usermod -a -G docker ec2-user
  sudo chmod 666 /var/run/docker.sock
  docker run -d -p 80:80 -p 443:443 ${var.container_image}
    EOF
  )

  iam_instance_profile {
    name = aws_iam_instance_profile.session-manager.id
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.ec2-sg.id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.ec2_instance_name}-instance"
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_nat_gateway.nat-gw]
}
