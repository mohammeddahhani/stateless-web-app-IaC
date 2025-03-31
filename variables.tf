variable "region" {
  description = "The AWS region to create resources in."
  type        = string
}

variable "aws_credentials" {
  description = "Path to aws credentials file"
  type        = list(string)
}

# networking
variable "vpc_cidr" {
  description = "CIDR Block for VPC"
  type        = string
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
}

variable "subnets" {
  description = "Map of public and private subnets with their CIDR blocks"
  type = map(map(string))
}

# load balancer
variable "health_check_path" {
  description = "Health check path for the default target group"
  type        = string
  default     = "/"
}


variable "instance_type" {
  description = "Instance type"
  type        = string
}

variable "ec2_instance_name" {
  description = "Name of the EC2 instance"
  type        = string
}

variable "container_image" {
  description = "Docker image for the web application"
  type        = string
}

# key pair

variable "public_key_path" {
  description = "Path to an SSH public key"
  type        = string
}

variable "key_path" {
  description = "Path to an SSH key - to be imported to the jump station"
  type        = string
}


variable "acm_certificate_arn" {
  description = "SSL Certificate arn "
  type        = string
  default = ""
}

# auto scaling

variable "autoscale_min" {
  description = "Minimum autoscale (number of EC2)"
  default     = "2"
}
variable "autoscale_max" {
  description = "Maximum autoscale (number of EC2)"
  default     = "2"
}
variable "autoscale_desired" {
  description = "Desired autoscale (number of EC2)"
  default     = "2"
}