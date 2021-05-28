output "lb_dns" {
  value = aws_lb.alb.dns_name
}
output "public_ip" {
  value = aws_instance.web.*.public_ip
}
