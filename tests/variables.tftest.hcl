// ────────────────────────────────────────────────────────────────────────────
// tests/variables.tftest.hcl
//
// Valida as regras de validacao de variaveis declaradas em variables.tf.
// Cada `run` faz plan; usamos `expect_failures` para confirmar que valores
// invalidos sao REJEITADOS antes de qualquer recurso ser criado.
//
// Executa via: terraform test -filter=tests/variables.tftest.hcl
// ────────────────────────────────────────────────────────────────────────────

// Mantemos o `localstack_endpoint` no default para que o provider AWS pule
// validacao de credenciais durante o plan. Os runs com `command = plan` nao
// fazem chamadas reais a LocalStack — apenas precisam de provider valido.
variables {
  environment              = "local"
  aws_region               = "us-east-1"
  localstack_endpoint      = "http://localhost:4566"
  create_network_resources = false
  create_api_gateway       = false
  default_timeout_ms       = 450
  app_port                 = 8080
}

// ── environment ─────────────────────────────────────────────────────────────

run "aceita_environment_local" {
  command = plan
  variables { environment = "local" }
  assert {
    condition     = var.environment == "local"
    error_message = "environment=local deveria ser aceito"
  }
}

run "aceita_environment_staging" {
  command = plan
  variables { environment = "staging" }
  assert {
    condition     = var.environment == "staging"
    error_message = "environment=staging deveria ser aceito"
  }
}

run "aceita_environment_prod" {
  command = plan
  variables { environment = "prod" }
  assert {
    condition     = var.environment == "prod"
    error_message = "environment=prod deveria ser aceito"
  }
}

run "rejeita_environment_qa" {
  command = plan
  variables { environment = "qa" }
  expect_failures = [var.environment]
}

run "rejeita_environment_dev" {
  command = plan
  variables { environment = "dev" }
  expect_failures = [var.environment]
}

// ── default_timeout_ms ──────────────────────────────────────────────────────

run "aceita_timeout_no_limite_inferior" {
  command = plan
  variables { default_timeout_ms = 1 }
  assert {
    condition     = var.default_timeout_ms == 1
    error_message = "default_timeout_ms=1 deveria ser aceito"
  }
}

run "aceita_timeout_no_limite_superior" {
  command = plan
  variables { default_timeout_ms = 499 }
  assert {
    condition     = var.default_timeout_ms == 499
    error_message = "default_timeout_ms=499 deveria ser aceito (P99 SLA de 500ms exclusive)"
  }
}

run "rejeita_timeout_zero" {
  command = plan
  variables { default_timeout_ms = 0 }
  expect_failures = [var.default_timeout_ms]
}

run "rejeita_timeout_negativo" {
  command = plan
  variables { default_timeout_ms = -10 }
  expect_failures = [var.default_timeout_ms]
}

run "rejeita_timeout_acima_de_500" {
  command = plan
  variables { default_timeout_ms = 500 }
  expect_failures = [var.default_timeout_ms]
}

run "rejeita_timeout_muito_alto" {
  command = plan
  variables { default_timeout_ms = 1000 }
  expect_failures = [var.default_timeout_ms]
}
