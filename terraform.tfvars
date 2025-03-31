
region                  = "eu-north-1"
public_key_path         = "~/.ssh/aws/key.pub"
key_path                = "~/.ssh/aws/key"
aws_credentials         = [".aws/credentials"]

vpc_cidr                = "10.0.0.0/16"

subnets = {
  public = {
    "public-subnet-1" = "10.0.1.0/24"
    "public-subnet-2" = "10.0.2.0/24"
  }
  private = {
    "private-subnet-1" = "10.0.10.0/24"
    "private-subnet-2" = "10.0.20.0/24"
  }
}

#ami_id = "ami-054ba1cb82f26097d" 

availability_zones      = ["eu-north-1a", "eu-north-1b", "eu-north-1c"]
instance_type           = "t3.micro"
ec2_instance_name       = "ec2_web"
container_image         = "nginxdemos/hello"

health_check_path       = "/"
acm_certificate_arn     = ""