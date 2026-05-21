variable "name_prefix" {
  description = "Naming prefix used as the SSM parameter path root."
  type        = string
}

variable "default_timeout_ms" {
  description = "Global HTTP timeout fallback in milliseconds. Must be < 500 (P99 SLA)."
  type        = number
  default     = 450
}

variable "app_port" {
  description = "Spring Boot HTTP port."
  type        = number
  default     = 8080
}

variable "spel_cache_max_size" {
  description = "Maximum pre-compiled SpEL expressions in Caffeine L1 per JVM."
  type        = number
  default     = 500
}

variable "spel_cache_expire_minutes" {
  description = "expireAfterAccess TTL in minutes for Caffeine L1 cache."
  type        = number
  default     = 60
}

variable "tags" {
  description = "Common tags applied to all resources in this module."
  type        = map(string)
  default     = {}
}
