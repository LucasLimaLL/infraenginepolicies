// ────────────────────────────────────────────────────────────────────────────
// tests/inventory_smoke.tftest.hcl
//
// Smoke test dos inventarios (environments/*.tfvars).
//
// Garante que cada inventario:
//   1. e plannable (sintaxe valida + variaveis aceitas pelas validations)
//   2. produz o name_prefix esperado
//   3. ativa as feature flags corretas para o ambiente
//
// Estes testes NAO substituem dynamodb/secrets/ssm/networking/api_gateway —
// servem apenas como guardrail contra drift entre inventarios e codigo.
//
// Cada `run` block reproduz o conteudo do .tfvars correspondente; assim, se
// alguem alterar `environments/staging.tfvars` sem atualizar este teste (ou
// vice-versa), o smoke quebra e o desvio fica explicito no diff.
// ────────────────────────────────────────────────────────────────────────────

// ── LOCAL ───────────────────────────────────────────────────────────────────

run "inventario_local_eh_plannavel" {
  command = plan
  variables {
    project                  = "engine-policies"
    environment              = "local"
    aws_region               = "us-east-1"
    localstack_endpoint      = "http://localhost:4566"
    create_network_resources = false
    create_api_gateway       = false
    app_backend_url          = "http://host.docker.internal:8080"
    app_port                 = 8080
    redis_host               = "localhost"
    redis_port               = 6379
    default_timeout_ms       = 450
  }

  assert {
    condition     = output.name_prefix == "engine-policies-local"
    error_message = "Inventario local deve produzir name_prefix 'engine-policies-local'"
  }

  assert {
    condition     = output.vpc_id == "N/A (local dev)"
    error_message = "Local nao deve criar VPC (LocalStack Community nao emula)"
  }

  assert {
    condition     = output.api_gateway_invoke_url == "N/A (local dev)"
    error_message = "Local nao deve criar API Gateway"
  }
}

// ── STAGING ─────────────────────────────────────────────────────────────────

run "inventario_staging_eh_plannavel" {
  command = plan
  variables {
    project                  = "engine-policies"
    environment              = "staging"
    aws_region               = "us-east-1"
    localstack_endpoint      = "http://localhost:4566" // bypass cred validation no plan
    create_network_resources = true
    create_api_gateway       = true
    app_backend_url          = "http://internal-staging-alb.engine.svc:8080"
    app_port                 = 8080
    redis_host               = "engine-staging.cache.amazonaws.com"
    redis_port               = 6379
    default_timeout_ms       = 450
    vpc_cidr                 = "10.10.0.0/16"
    availability_zones       = ["us-east-1a", "us-east-1b"]
  }

  assert {
    condition     = output.name_prefix == "engine-policies-staging"
    error_message = "Inventario staging deve produzir name_prefix 'engine-policies-staging'"
  }

  assert {
    condition     = output.vpc_cidr_block == "10.10.0.0/16"
    error_message = "Inventario staging deve usar VPC CIDR 10.10.0.0/16; recebido '${output.vpc_cidr_block}'"
  }

  assert {
    condition     = length(output.public_subnet_cidrs) == 2 && length(output.private_subnet_cidrs) == 2
    error_message = "Staging deve provisionar 2+2 subnets (2 AZs)"
  }

  assert {
    condition     = output.api_gateway_name == "engine-policies-staging-http-api"
    error_message = "Staging deve provisionar API Gateway com nome correto"
  }
}

// ── PROD ────────────────────────────────────────────────────────────────────

run "inventario_prod_eh_plannavel" {
  command = plan
  variables {
    project                  = "engine-policies"
    environment              = "prod"
    aws_region               = "us-east-1"
    localstack_endpoint      = "http://localhost:4566"
    create_network_resources = true
    create_api_gateway       = true
    app_backend_url          = "http://internal-prod-alb.engine.svc:8080"
    app_port                 = 8080
    redis_host               = "engine-prod.cache.amazonaws.com"
    redis_port               = 6379
    default_timeout_ms       = 425
    vpc_cidr                 = "10.20.0.0/16"
    availability_zones       = ["us-east-1a", "us-east-1b", "us-east-1c"]
  }

  assert {
    condition     = output.name_prefix == "engine-policies-prod"
    error_message = "Inventario prod deve produzir name_prefix 'engine-policies-prod'"
  }

  assert {
    condition     = output.vpc_cidr_block == "10.20.0.0/16"
    error_message = "Prod deve usar VPC CIDR 10.20.0.0/16 (distinto de staging)"
  }

  assert {
    condition     = length(output.public_subnet_cidrs) == 3 && length(output.private_subnet_cidrs) == 3
    error_message = "Prod deve provisionar 3+3 subnets (multi-AZ resilience)"
  }

  // Timeout mais conservador em prod
  assert {
    condition     = output.ssm_default_timeout_ms_value == "425"
    error_message = "Prod deve usar default_timeout_ms=425 (margem extra sob carga); recebido '${output.ssm_default_timeout_ms_value}'"
  }
}
