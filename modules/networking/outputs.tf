output "vpc_id" {
  description = "ID of the provisioned VPC."
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs."
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs."
  value       = aws_subnet.private[*].id
}

output "fargate_sg_id" {
  description = "Security group ID for ECS Fargate tasks."
  value       = aws_security_group.fargate.id
}

output "redis_sg_id" {
  description = "Security group ID for ElastiCache Redis."
  value       = aws_security_group.redis.id
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway."
  value       = aws_internet_gateway.main.id
}
