// ────────────────────────────────────────────────────────────────────────────
// tests/apply_localstack.tftest.hcl
//
// Teste end-to-end com `command = apply` REAL contra LocalStack.
//
// REQUISITOS:
//   - LocalStack rodando em http://localhost:4566 (docker-compose up localstack)
//   - O `terraform.tfvars.example` mostra a configuracao esperada
//
// Diferenca para os outros .tftest.hcl deste diretorio:
//   - Demais arquivos: command = plan (estatico, sem AWS)
//   - Este arquivo: command = apply (cria recursos de verdade em LocalStack)
//   - Apos o `apply`, asserts validam que os recursos REAIS foram criados
//     com as configuracoes esperadas, e que NENHUM atributo virou default
//     silenciosamente.
//
// COMO RODAR:
//   docker compose -f ../appenginepolicies/docker-compose.yml up -d localstack
//   terraform init -backend=false
//   terraform test -filter=tests/apply_localstack.tftest.hcl
//
// COMO PULAR (CI sem LocalStack):
//   terraform test -filter=tests/variables.tftest.hcl \
//                  -filter=tests/dynamodb.tftest.hcl \
//                  -filter=tests/secrets.tftest.hcl \
//                  -filter=tests/ssm.tftest.hcl \
//                  -filter=tests/feature_flags.tftest.hcl \
//                  -filter=tests/name_prefix.tftest.hcl
// ────────────────────────────────────────────────────────────────────────────

variables {
  environment              = "local"
  aws_region               = "us-east-1"
  localstack_endpoint      = "http://localhost:4566"
  create_network_resources = false
  create_api_gateway       = false
  default_timeout_ms       = 425
  app_port                 = 8080
}

run "apply_stack_completa_em_localstack" {
  command = apply

  // 1. DynamoDB criado e acessivel
  assert {
    condition     = output.dynamodb_table_name == "politicas"
    error_message = "Tabela DynamoDB nao foi criada com nome 'politicas'"
  }
  assert {
    condition     = length(output.dynamodb_table_arn) > 0
    error_message = "ARN do DynamoDB nao foi gerado apos apply"
  }

  // 2. Estrutura da tabela preservada apos apply
  assert {
    condition     = output.dynamodb_hash_key == "scenario"
    error_message = "Apos apply, hash_key deve ser 'scenario'"
  }
  assert {
    condition     = output.dynamodb_range_key == "prioridade"
    error_message = "Apos apply, range_key deve ser 'prioridade'"
  }
  assert {
    condition     = output.dynamodb_billing_mode == "PAY_PER_REQUEST"
    error_message = "Apos apply, billing_mode deve ser PAY_PER_REQUEST"
  }
  assert {
    condition     = output.dynamodb_ttl_attribute_name == "expiracao"
    error_message = "Apos apply, TTL deve apontar para 'expiracao'"
  }

  // 3. Secrets criados com nomes corretos
  assert {
    condition     = output.secrets_redis_name == "engine-policies-local/redis-credentials"
    error_message = "Secret Redis nao foi criado com o nome esperado"
  }
  assert {
    condition     = length(output.secrets_redis_arn) > 0
    error_message = "ARN do secret Redis nao foi gerado apos apply"
  }
  assert {
    condition     = output.secrets_app_tokens_name == "engine-policies-local/app-tokens"
    error_message = "Secret de tokens nao foi criado com o nome esperado"
  }

  // 4. SSM com valores EXATOS passados via variavel
  assert {
    condition     = output.ssm_default_timeout_ms_name == "/engine-policies-local/default-timeout-ms"
    error_message = "Parametro SSM de timeout nao foi criado no caminho esperado"
  }
  assert {
    condition     = output.ssm_default_timeout_ms_value == "425"
    error_message = "Apos apply, valor SSM deve refletir var.default_timeout_ms=425; recebido '${output.ssm_default_timeout_ms_value}'"
  }
  assert {
    condition     = output.ssm_app_port_value == "8080"
    error_message = "Apos apply, valor SSM de app_port deve refletir var.app_port=8080"
  }

  // 5. Feature flags respeitadas (sem network/api_gateway em local)
  assert {
    condition     = output.vpc_id == "N/A (local dev)"
    error_message = "VPC nao deveria ter sido criada em local dev"
  }
  assert {
    condition     = output.api_gateway_invoke_url == "N/A (local dev)"
    error_message = "API Gateway nao deveria ter sido criado em local dev"
  }
}
