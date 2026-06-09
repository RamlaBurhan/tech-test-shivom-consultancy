output "vpc_id" {
  value       = aws_vpc.this.id
  description = "ID of the VPC"
}

output "vpc_cidr" {
  value       = aws_vpc.this.cidr_block
  description = "CIDR block of the VPC"
}

output "public_subnet_ids" {
  value       = aws_subnet.public[*].id
  description = "IDs of the public subnets"
}
