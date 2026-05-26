// ────────────────────────────────────────────────────────────────────────────
// tests/name_prefix.tftest.hcl
//
// Valida que o `name_prefix` composto e propagado consistentemente para todos
// os recursos. A regra de composicao e `${var.project}-${var.environment}`.
// Estes testes garantem que NENHUM recurso usa nome hardcoded por engano.
// ────────────────────────────────────────────────────────────────────────────

variables {
  environment              = "local"
  aws_region               = "us-east-1"
  localstack_endpoint      = "http://localhost:4566"
  create_network_resources = false
  create_api_gateway       = false
}

run "name_prefix_composto_por_project_e_environment" {
  command = plan

  assert {
    condition     = output.name_prefix == "engine-policies-local"
    error_message = "name_prefix esperado 'engine-policies-local'; recebido '${output.name_prefix}'"
  }
}

run "name_prefix_acompanha_environment_staging" {
  command = plan
  variables { environment = "staging" }

  assert {
    condition     = output.name_prefix == "engine-policies-staging"
    error_message = "name_prefix em staging deve ser 'engine-policies-staging'"
  }
}

run "name_prefix_acompanha_environment_prod" {
  command = plan
  variables { environment = "prod" }

  assert {
    condition     = output.name_prefix == "engine-policies-prod"
    error_message = "name_prefix em prod deve ser 'engine-policies-prod'"
  }
}

run "secrets_e_ssm_compartilham_o_mesmo_prefixo_em_staging" {
  command = plan
  variables { environment = "staging" }

  assert {
    condition = (
      startswith(output.secrets_redis_name, "engine-policies-staging/") &&
      startswith(output.ssm_default_timeout_ms_name, "/engine-policies-staging/") &&
      startswith(output.ssm_app_port_name, "/engine-policies-staging/")
    )
    error_message = "Secrets e SSM devem compartilhar o prefixo 'engine-policies-staging' em todos os nomes"
  }
}
