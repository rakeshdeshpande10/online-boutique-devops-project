output "vpc_id" {
    description = "The ID of the VPC"
    value       = aws_vpc.main.id
}

output "private_subnet_ids" {
    description = "The IDs of the private subnets"
    value       = [aws_subnet.private_subnet1.id, aws_subnet.private_subnet2.id]
}

output "public_subnet_ids" {
    description = "The IDs of the public subnets"
    value       = [aws_subnet.public_subnet1.id, aws_subnet.public_subnet2.id]
}