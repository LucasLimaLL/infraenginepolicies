// ────────────────────────────────────────────────────────────────────────────
// tests/apply_aws.tftest.hcl
//
// E2E APPLY REAL CONTRA AWS — NAO ROTA EM CI POR PADRAO.
//
// Este arquivo materializa a stack INTEIRA em AWS real (DynamoDB, Secrets,
// SSM, Networking E API Gateway). Apos o apply, asserts validam:
//   - ARNs reais foram gerados
//   - Valores armazenados correspondem exatamente as variaveis de input
//   - VPC e API Gateway criados nas regioes/AZs esperadas
//
// REQUISITOS:
//   1. Credenciais AWS configuradas (AWS_PROFILE, AWS_ACCESS_KEY_ID, OIDC, etc.)
//   2. Backend S3 configurado para state (ou comente o `backend "s3" {}` em
//      versions.tf para usar state local)
//   3. Permissoes IAM para criar DynamoDB, Secrets, SSM, VPC, API Gateway
//
// COMO RODAR (manual, fora do CI):
//   export AWS_PROFILE=engine-staging
//   terraform init \
//     -backend-config="bucket=$TF_BACKEND_BUCKET" \
//     -backend-config="key=infraenginepolicies/test/terraform.tfstate" \
//     -backend-config="region=us-east-1"
//   terraform test -filter=tests/apply_aws.tftest.hcl
//
// IMPORTANTE: este teste CRIA E DESTROI recursos AWS reais. O terraform test
// faz `terraform destroy` automaticamente ao fim do run block.
// ────────────────────────────────────────────────────────────────────────────

variables {
  environment              = "staging"
  aws_region               = "us-east-1"
  localstack_endpoint      = "" // STRING VAZIA = AWS real (sem LocalStack override)
  create_network_resources = true
  create_api_gateway       = true
  default_timeout_ms       = 425
  app_port                 = 8080
  vpc_cidr                 = "10.42.0.0/16"
  availability_zones       = ["us-east-1a", "us-east-1b"]
  app_backend_url          = "http://internal-engine.staging:8080"
}

run "stack_completa_em_aws_real" {
  command = apply

  // ── 1. Identidade da stack ────────────────────────────────────────────────
  assert {
    condition     = output.name_prefix == "engine-policies-staging"
    error_message = "Stack deve ter prefixo 'engine-policies-staging'; recebido '${output.name_prefix}'"
  }

  // ── 2. DynamoDB ───────────────────────────────────────────────────────────
  assert {
    condition     = output.dynamodb_table_name == "politicas"
    error_message = "Tabela DynamoDB deve se chamar 'politicas' (nome fixo, nao prefixado)"
  }
  assert {
    condition     = startswith(output.dynamodb_table_arn, "arn:aws:dynamodb:us-east-1:")
    error_message = "ARN DynamoDB deve comecar com 'arn:aws:dynamodb:us-east-1:' (AWS real, nao LocalStack); recebido '${output.dynamodb_table_arn}'"
  }
  assert {
    condition     = output.dynamodb_billing_mode == "PAY_PER_REQUEST" && output.dynamodb_pitr_enabled == true
    error_message = "DynamoDB deve estar em PAY_PER_REQUEST com PITR habilitado"
  }

  // ── 3. Secrets Manager ────────────────────────────────────────────────────
  assert {
    condition     = startswith(output.secrets_redis_arn, "arn:aws:secretsmanager:us-east-1:")
    error_message = "ARN do secret Redis deve comecar com 'arn:aws:secretsmanager:us-east-1:'"
  }
  assert {
    condition     = output.secrets_redis_recovery_window_in_days == 7
    error_message = "Recovery window do secret Redis deve ser 7 dias"
  }

  // ── 4. SSM Parameters ─────────────────────────────────────────────────────
  assert {
    condition     = output.ssm_default_timeout_ms_value == "425"
    error_message = "Apos apply em AWS real, valor SSM deve refletir var.default_timeout_ms=425"
  }
  assert {
    condition     = output.ssm_app_port_value == "8080"
    error_message = "Apos apply em AWS real, valor SSM de app_port deve ser 8080"
  }

  // ── 5. Networking ─────────────────────────────────────────────────────────
  assert {
    condition     = startswith(output.vpc_id, "vpc-")
    error_message = "vpc_id deve seguir o padrao 'vpc-xxxxx' da AWS real; recebido '${output.vpc_id}'"
  }
  assert {
    condition     = output.vpc_cidr_block == "10.42.0.0/16"
    error_message = "VPC deve usar o CIDR customizado 10.42.0.0/16"
  }
  assert {
    condition     = length(output.public_subnet_ids) == 2 && length(output.private_subnet_ids) == 2
    error_message = "Devem existir 2 subnets publicas e 2 privadas"
  }
  assert {
    condition     = length(output.redis_ingress_cidr_blocks) == 0
    error_message = "VIOLACAO DE SEGURANCA: Redis SG aceita CIDR blocks em AWS real"
  }

  // ── 6. API Gateway ────────────────────────────────────────────────────────
  assert {
    condition     = startswith(output.api_gateway_invoke_url, "https://") && endswith(output.api_gateway_invoke_url, ".amazonaws.com")
    error_message = "API Gateway invoke_url deve ser uma URL HTTPS amazonaws.com real; recebido '${output.api_gateway_invoke_url}'"
  }
  assert {
    condition     = output.api_gateway_protocol == "HTTP"
    error_message = "API Gateway deve usar protocolo HTTP v2 (nao REST v1)"
  }
  assert {
    condition     = output.api_gateway_route_key == "ANY /v1/motor/{proxy+}"
    error_message = "Route key deve ser 'ANY /v1/motor/{proxy+}'"
  }
  assert {
    condition     = output.api_gateway_payload_format == "1.0"
    error_message = "payload_format deve ser 1.0 para preservar raw body"
  }
}
