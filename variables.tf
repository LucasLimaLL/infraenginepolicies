# ─── Project Identity ────────────────────────────────────────────────────────

variable "project" {
  description = "Project name prefix applied to all resource names and tags."
  type        = string
  default     = "engine-policies"
}

variable "environment" {
  description = "Deployment environment identifier (local | staging | prod)."
  type        = string
  default     = "local"

  validation {
    condition     = contains(["local", "staging", "prod"], var.environment)
    error_message = "environment must be one of: local, staging, prod."
  }
}

# ─── AWS Provider ────────────────────────────────────────────────────────────

variable "aws_region" {
  description = "AWS region for all resources."
  type        = string
  default     = "us-east-1"
}

variable "localstack_endpoint" {
  description = <<-EOT
    LocalStack base endpoint URL (e.g. http://localhost:4566).
    Set to empty string "" to target real AWS.
    When non-empty the provider skips credential/account-id validation.
  EOT
  type        = string
  default     = "http://localhost:4566"
}

# ─── Feature Toggles ─────────────────────────────────────────────────────────

variable "create_network_resources" {
  description = <<-EOT
    Whether to create VPC, subnets, Internet Gateway and Security Groups.
    Disable for local dev — LocalStack Community does not emulate EC2/VPC.
  EOT
  type    = bool
  default = false
}

variable "create_api_gateway" {
  description = <<-EOT
    Whether to create the HTTP API Gateway v2 and CloudWatch log group.
    Disable for local dev — LocalStack Community does not emulate API Gateway.
  EOT
  type    = bool
  default = false
}

# ─── Application ─────────────────────────────────────────────────────────────

variable "app_backend_url" {
  description = <<-EOT
    Backend URL injected into the API Gateway HTTP integration.
    Local dev default uses host.docker.internal to reach Spring Boot from inside Docker.
  EOT
  type    = string
  default = "http://host.docker.internal:8080"
}

variable "app_port" {
  description = "Spring Boot application HTTP port (stored in SSM for the app to read at startup)."
  type        = number
  default     = 8080
}

# ─── Redis / ElastiCache ─────────────────────────────────────────────────────

variable "redis_host" {
  description = "Redis host stored in Secrets Manager. Use 'localhost' for local dev."
  type        = string
  default     = "localhost"
}

variable "redis_port" {
  description = "Redis port stored in Secrets Manager."
  type        = number
  default     = 6379
}

variable "redis_password" {
  description = "Redis AUTH password stored in Secrets Manager. Empty string disables AUTH."
  type        = string
  default     = ""
  sensitive   = true
}

# ─── SSM Parameters ──────────────────────────────────────────────────────────

variable "default_timeout_ms" {
  description = <<-EOT
    Global fallback HTTP timeout in milliseconds for the rule executor.
    Must be below the P99 SLA of 500ms. Overridden per rule via timeout_ms in DynamoDB.
  EOT
  type    = number
  default = 450

  validation {
    condition     = var.default_timeout_ms > 0 && var.default_timeout_ms < 500
    error_message = "default_timeout_ms must be between 1 and 499 to honour the P99 SLA."
  }
}

# ─── Networking ──────────────────────────────────────────────────────────────

variable "vpc_cidr" {
  description = "CIDR block for the VPC (prod only — ignored when create_network_resources = false)."
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of AZs for subnet distribution (prod only)."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}
