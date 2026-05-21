variable "name_prefix" {
  description = "Naming prefix for tags."
  type        = string
}

variable "tags" {
  description = "Common tags applied to all resources in this module."
  type        = map(string)
  default     = {}
}
