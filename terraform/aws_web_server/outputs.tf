output "lb_ip_addr" {
  value = aws_lb.web_lb.dns_name
}
