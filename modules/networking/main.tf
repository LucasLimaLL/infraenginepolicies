# ─────────────────────────────────────────────────────────────────────────────
# Module: networking
#
# Provisions the VPC topology for the engine in production:
#   - Public subnets  → Internet Gateway, NAT (future ALB)
#   - Private subnets → ECS Fargate tasks, ElastiCache Redis
#   - Security Groups → enforce least-privilege between tiers
#
# This module is NOT applied in local dev (LocalStack Community does not
# emulate VPC/EC2). Toggle via create_network_resources = true in tfvars.
# ─────────────────────────────────────────────────────────────────────────────

# ── VPC ───────────────────────────────────────────────────────────────────────

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-vpc"
  })
}

# ── Internet Gateway ──────────────────────────────────────────────────────────

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-igw"
  })
}

# ── Public Subnets ────────────────────────────────────────────────────────────
# CIDR: 10.0.1.0/24, 10.0.2.0/24 (one per AZ)

resource "aws_subnet" "public" {
  count = length(var.availability_zones)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index + 1)
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-subnet-public-${var.availability_zones[count.index]}"
    Tier = "public"
  })
}

# ── Private Subnets ───────────────────────────────────────────────────────────
# CIDR: 10.0.10.0/24, 10.0.20.0/24 (one per AZ)

resource "aws_subnet" "private" {
  count = length(var.availability_zones)

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 10)
  availability_zone = var.availability_zones[count.index]

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-subnet-private-${var.availability_zones[count.index]}"
    Tier = "private"
  })
}

# ── Public Route Table ────────────────────────────────────────────────────────

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-rt-public"
  })
}

resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# ── Security Group — ECS Fargate ──────────────────────────────────────────────
# Allows inbound HTTP on 8080 (from API Gateway / ALB).
# Allows all outbound (DynamoDB VPC endpoint, ElastiCache, external HTTP APIs).

resource "aws_security_group" "fargate" {
  name        = "${var.name_prefix}-sg-fargate"
  description = "ECS Fargate tasks running the engine — inbound 8080, outbound all."
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from API Gateway or ALB"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound traffic (DynamoDB, ElastiCache, external partner APIs)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-sg-fargate"
    Tier = "application"
  })
}

# ── Security Group — ElastiCache Redis ───────────────────────────────────────
# Port 6379 reachable only from Fargate tasks SG.
# No other ingress allowed — never expose Redis to the internet.

resource "aws_security_group" "redis" {
  name        = "${var.name_prefix}-sg-redis"
  description = "ElastiCache Redis L2 cache — port 6379 from Fargate SG only."
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Redis from Fargate tasks only"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.fargate.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-sg-redis"
    Tier = "cache"
  })
}
