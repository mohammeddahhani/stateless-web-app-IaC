resource "aws_key_pair" "ssh-key" {
  key_name   = "pub-key"
  public_key = file(var.public_key_path)
}
