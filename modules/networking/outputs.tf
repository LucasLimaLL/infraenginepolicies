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

output "vpc_cidr_block" {
  description = "CIDR block of the VPC."
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_cidrs" {
  description = "List of CIDR blocks for the public subnets."
  value       = aws_subnet.public[*].cidr_block
}

output "private_subnet_cidrs" {
  description = "List of CIDR blocks for the private subnets."
  value       = aws_subnet.private[*].cidr_block
}

output "fargate_ingress_ports" {
  description = "List of inbound TCP ports allowed on the Fargate SG."
  value       = [for r in aws_security_group.fargate.ingress : r.from_port]
}

output "redis_ingress_source_sg_ids" {
  description = "Security group IDs allowed to reach the Redis SG (should reference the Fargate SG)."
  value       = flatten([for r in aws_security_group.redis.ingress : r.security_groups])
}

output "redis_ingress_cidr_blocks" {
  description = "CIDR blocks allowed on the Redis SG ingress. Should be EMPTY (Redis must never be exposed to the internet)."
  value       = flatten([for r in aws_security_group.redis.ingress : r.cidr_blocks])
}
