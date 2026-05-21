locals {
  name_prefix  = "${var.project}-${var.environment}"
  is_local_dev = var.localstack_endpoint != ""

  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
    Repository  = "infraenginepolicies"
  }
}
