output "public_ec2_public_ip" {
  value       = aws_instance.ec2_for_public_subnet.public_ip
  sensitive   = false
  description = "Public ip"
}