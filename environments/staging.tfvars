# ─────────────────────────────────────────────────────────────────────────────
# environments/staging.tfvars
#
# Inventario STAGING — espelho funcional da producao com massa reduzida.
# Roda em AWS real, com flags de rede/API Gateway ON.
#
# Uso:
#   AWS_PROFILE=engine-staging terraform plan  -var-file=environments/staging.tfvars
#   AWS_PROFILE=engine-staging terraform apply -var-file=environments/staging.tfvars
# ─────────────────────────────────────────────────────────────────────────────

project     = "engine-policies"
environment = "staging"
aws_region  = "us-east-1"

# AWS real — sem override de endpoint
localstack_endpoint      = ""
create_network_resources = true
create_api_gateway       = true

# Backend interno via ALB (DNS resolvido pelo Route53 privado)
app_backend_url = "http://internal-staging-alb.engine.svc:8080"
app_port        = 8080

# ElastiCache Redis (provisionado fora deste repositorio)
redis_host = "engine-staging.cache.amazonaws.com"
redis_port = 6379
# redis_password injetado via Secrets Manager rotation — nunca em tfvars

# SLA P99 alinhado com producao
default_timeout_ms = 450

# Network — espelha producao em CIDR e topologia, 2 AZs
vpc_cidr           = "10.10.0.0/16"
availability_zones = ["us-east-1a", "us-east-1b"]
