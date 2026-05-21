variable "name_prefix" {
  description = "Naming prefix for API Gateway resources."
  type        = string
}

variable "app_backend_url" {
  description = <<-EOT
    Backend base URL injected into the HTTP_PROXY integration.
    Local dev: http://host.docker.internal:8080
    Production: http://<internal-alb-dns-name>
  EOT
  type    = string
  default = "http://host.docker.internal:8080"
}

variable "tags" {
  description = "Common tags applied to all resources in this module."
  type        = map(string)
  default     = {}
}
