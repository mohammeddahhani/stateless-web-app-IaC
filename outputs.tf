output "alb_dns" {
  value = aws_lb.main-alb.dns_name
}

output "jumpstation_public_ip" {
  description = "Public IP address of the Jumpstation"
  value       = aws_instance.jumpstation.public_ip
}


output "alb_zone" {
  value = aws_lb.main-alb.zone_id
}
