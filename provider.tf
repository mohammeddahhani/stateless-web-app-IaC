provider "aws" {
  shared_credentials_files = var.aws_credentials 
  region = var.region
}