// ────────────────────────────────────────────────────────────────────────────
// tests/ssm.tftest.hcl
//
// Valida que cada parametro SSM:
//   - tem o caminho prefixado /{project}-{environment}/{nome-do-parametro}
//   - armazena o VALOR exato passado via variavel de input
//   - nao usa o default do modulo silenciosamente quando o root sobrescreve
//
// Em particular `default_timeout_ms` e `app_port` sao passados pelo root,
// enquanto `spel_cache_max_size` e `spel_cache_expire_minutes` usam defaults
// do modulo (500 e 60).
// ────────────────────────────────────────────────────────────────────────────

variables {
  environment              = "local"
  aws_region               = "us-east-1"
  localstack_endpoint      = "http://localhost:4566"
  create_network_resources = false
  create_api_gateway       = false
  default_timeout_ms       = 450
  app_port                 = 8080
}

run "default_timeout_ms_tem_caminho_correto" {
  command = plan

  assert {
    condition     = output.ssm_default_timeout_ms_name == "/engine-policies-local/default-timeout-ms"
    error_message = "Caminho SSM esperado '/engine-policies-local/default-timeout-ms'; recebido '${output.ssm_default_timeout_ms_name}'"
  }
}

run "default_timeout_ms_armazena_valor_passado_por_variavel" {
  command = plan
  variables { default_timeout_ms = 350 }

  assert {
    condition     = output.ssm_default_timeout_ms_value == "350"
    error_message = "Valor SSM deve refletir var.default_timeout_ms=350; recebido '${output.ssm_default_timeout_ms_value}'"
  }
}

run "default_timeout_ms_no_limite_superior" {
  command = plan
  variables { default_timeout_ms = 499 }

  assert {
    condition     = output.ssm_default_timeout_ms_value == "499"
    error_message = "Valor SSM deve ser 499 (limite SLA); recebido '${output.ssm_default_timeout_ms_value}'"
  }
}

run "app_port_armazena_valor_passado" {
  command = plan
  variables { app_port = 8888 }

  assert {
    condition     = output.ssm_app_port_value == "8888"
    error_message = "Valor SSM de app_port deve refletir var.app_port=8888; recebido '${output.ssm_app_port_value}'"
  }
}

run "app_port_tem_caminho_correto" {
  command = plan

  assert {
    condition     = output.ssm_app_port_name == "/engine-policies-local/app-port"
    error_message = "Caminho SSM esperado '/engine-policies-local/app-port'; recebido '${output.ssm_app_port_name}'"
  }
}

run "spel_cache_max_size_tem_caminho_correto" {
  command = plan

  assert {
    condition     = output.ssm_spel_cache_max_size_name == "/engine-policies-local/spel-cache-max-size"
    error_message = "Caminho esperado '/engine-policies-local/spel-cache-max-size'; recebido '${output.ssm_spel_cache_max_size_name}'"
  }
}

run "spel_cache_expire_minutes_tem_caminho_correto" {
  command = plan

  assert {
    condition     = output.ssm_spel_cache_expire_minutes_name == "/engine-policies-local/spel-cache-expire-minutes"
    error_message = "Caminho esperado '/engine-policies-local/spel-cache-expire-minutes'; recebido '${output.ssm_spel_cache_expire_minutes_name}'"
  }
}

run "prefixo_muda_com_environment_prod" {
  command = plan
  variables {
    environment        = "prod"
    default_timeout_ms = 400
  }

  assert {
    condition     = output.ssm_default_timeout_ms_name == "/engine-policies-prod/default-timeout-ms"
    error_message = "Prefixo deve refletir environment=prod; recebido '${output.ssm_default_timeout_ms_name}'"
  }

  assert {
    condition     = output.ssm_default_timeout_ms_value == "400"
    error_message = "Valor em prod deve ser 400 (passado via variavel)"
  }
}
