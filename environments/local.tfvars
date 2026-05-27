# ─────────────────────────────────────────────────────────────────────────────
# environments/local.tfvars
#
# Inventario LOCAL — usado para desenvolvimento contra LocalStack.
# Equivalente ao 'hosts.local.ini' do Ansible: configura a unica diferenca
# entre ambientes (endpoints, flags, hosts) sem alterar codigo.
#
# Uso:
#   terraform plan  -var-file=environments/local.tfvars
#   terraform apply -var-file=environments/local.tfvars
#   terraform test  -var-file=environments/local.tfvars
#
# IMPORTANTE: este arquivo NAO contem segredos. Senhas e tokens vem de
# variaveis de ambiente, AWS Secrets Manager ou injecao via -var no apply.
# ─────────────────────────────────────────────────────────────────────────────

project     = "engine-policies"
environment = "local"
aws_region  = "us-east-1"

# LocalStack Community emula DynamoDB/Secrets/SSM mas nao VPC/EC2/APIGw
localstack_endpoint      = "http://localhost:4566"
create_network_resources = false
create_api_gateway       = false

# Backend Spring Boot acessivel desde container LocalStack (Docker network)
app_backend_url = "http://host.docker.internal:8080"
app_port        = 8080

# Redis local rodando via docker-compose
redis_host = "localhost"
redis_port = 6379
# redis_password vem via -var ou variavel de ambiente (nunca em arquivo versionado)

# SLA P99 de 500ms — global fallback
default_timeout_ms = 450
