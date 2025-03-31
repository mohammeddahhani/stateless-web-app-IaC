output "alb_dns" {
  value = aws_lb.main-alb.dns_name
}
output "alb_zone" {
  value = aws_lb.main-alb.zone_id
}