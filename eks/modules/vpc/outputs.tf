output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "private_subnet_ids" {
  description = "IDs of th private subnet"
  value       = aws_subnet.private[*].id 
}

output "public_subnet_ids" {
  description = "IDs of the piblic subnet"
  value       = aws_subnet.public[*].id
}
