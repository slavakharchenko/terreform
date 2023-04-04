output "vpc_id" {
  value       = aws_vpc.terraform_vpc.id
  sensitive   = false
  description = "Vpc id"
}

output "private_subnet" {
  value       = aws_subnet.terraform_private_subnet.id
  sensitive   = false
  description = "Private subnet id"
}

output "public_subnet" {
  value       = aws_subnet.terraform_public_subnet.id
  sensitive   = false
  description = "Public subnet id"
}