# ─────────────────────────────────────────────────────────────────────────────
# environments/prod.tfvars
#
# Inventario PRODUCAO — config final do ambiente B2B.
# Multi-AZ, timeout mais conservador (margem extra sob carga real).
#
# Uso (apenas com aprovacao via GitHub Environment 'prod'):
#   AWS_PROFILE=engine-prod terraform plan  -var-file=environments/prod.tfvars
#   AWS_PROFILE=engine-prod terraform apply -var-file=environments/prod.tfvars
# ─────────────────────────────────────────────────────────────────────────────

project     = "engine-policies"
environment = "prod"
aws_region  = "us-east-1"

localstack_endpoint      = ""
create_network_resources = true
create_api_gateway       = true

app_backend_url = "http://internal-prod-alb.engine.svc:8080"
app_port        = 8080

redis_host = "engine-prod.cache.amazonaws.com"
redis_port = 6379
# redis_password injetado via Secrets Manager rotation

# Timeout um pouco mais conservador em prod — margem para spikes
default_timeout_ms = 425

# Multi-AZ (3 zonas) para resiliencia
vpc_cidr           = "10.20.0.0/16"
availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
