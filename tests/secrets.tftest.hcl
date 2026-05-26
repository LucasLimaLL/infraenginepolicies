// ────────────────────────────────────────────────────────────────────────────
// tests/secrets.tftest.hcl
//
// Valida que os secrets do AWS Secrets Manager sao criados com:
//   - nomes prefixados por {project}-{environment}
//   - recovery_window_in_days = 7
//   - sufixos corretos: /redis-credentials e /app-tokens
//
// O conteudo dos secrets nao e validado (sao opacos e sensitive=true).
// ────────────────────────────────────────────────────────────────────────────

variables {
  environment              = "local"
  aws_region               = "us-east-1"
  localstack_endpoint      = "http://localhost:4566"
  create_network_resources = false
  create_api_gateway       = false
}

run "redis_secret_tem_prefixo_e_sufixo_corretos" {
  command = plan

  assert {
    condition     = output.secrets_redis_name == "engine-policies-local/redis-credentials"
    error_message = "Nome do secret Redis esperado 'engine-policies-local/redis-credentials'; recebido '${output.secrets_redis_name}'"
  }
}

run "app_tokens_secret_tem_prefixo_e_sufixo_corretos" {
  command = plan

  assert {
    condition     = output.secrets_app_tokens_name == "engine-policies-local/app-tokens"
    error_message = "Nome do secret de tokens esperado 'engine-policies-local/app-tokens'; recebido '${output.secrets_app_tokens_name}'"
  }
}

run "redis_secret_tem_recovery_window_de_7_dias" {
  command = plan

  assert {
    condition     = output.secrets_redis_recovery_window_in_days == 7
    error_message = "Recovery window do secret Redis deve ser 7 dias; recebido '${output.secrets_redis_recovery_window_in_days}'"
  }
}

run "nome_do_secret_redis_muda_com_environment" {
  command = plan
  variables { environment = "prod" }

  assert {
    condition     = output.secrets_redis_name == "engine-policies-prod/redis-credentials"
    error_message = "Em prod o secret Redis deve ser 'engine-policies-prod/redis-credentials'; recebido '${output.secrets_redis_name}'"
  }
}

run "nome_do_secret_tokens_muda_com_environment_staging" {
  command = plan
  variables { environment = "staging" }

  assert {
    condition     = output.secrets_app_tokens_name == "engine-policies-staging/app-tokens"
    error_message = "Em staging o secret de tokens deve ser 'engine-policies-staging/app-tokens'; recebido '${output.secrets_app_tokens_name}'"
  }
}
