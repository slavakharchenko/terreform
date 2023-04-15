output "alb_public_ip" {
  value = aws_lb.terraform-application-lb.dns_name
}