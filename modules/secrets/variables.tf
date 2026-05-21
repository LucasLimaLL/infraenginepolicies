variable "name_prefix" {
  description = "Naming prefix for secret paths (e.g. engine-policies-local)."
  type        = string
}

variable "redis_host" {
  description = "Redis/ElastiCache host address."
  type        = string
}

variable "redis_port" {
  description = "Redis/ElastiCache port."
  type        = number
  default     = 6379
}

variable "redis_password" {
  description = "Redis AUTH password. Empty string disables AUTH (local dev)."
  type        = string
  sensitive   = true
  default     = ""
}

variable "tags" {
  description = "Common tags applied to all resources in this module."
  type        = map(string)
  default     = {}
}
