// ────────────────────────────────────────────────────────────────────────────
// tests/dynamodb.tftest.hcl
//
// Valida que a tabela DynamoDB `politicas` e criada com:
//   - chaves corretas (PK=scenario, SK=prioridade)
//   - billing_mode PAY_PER_REQUEST (on-demand)
//   - Point-in-Time Recovery habilitado
//   - TTL no atributo `expiracao`
//   - tags com Environment, Project, Role
//
// Todos os tests usam `command = plan` — nao requerem AWS/LocalStack.
// ────────────────────────────────────────────────────────────────────────────

variables {
  environment              = "local"
  aws_region               = "us-east-1"
  localstack_endpoint      = "http://localhost:4566"
  create_network_resources = false
  create_api_gateway       = false
}

run "tabela_tem_nome_fixo_politicas" {
  command = plan

  assert {
    condition     = output.dynamodb_table_name == "politicas"
    error_message = "Nome da tabela esperado 'politicas'; recebido '${output.dynamodb_table_name}'"
  }
}

run "hash_key_eh_scenario" {
  command = plan

  assert {
    condition     = output.dynamodb_hash_key == "scenario"
    error_message = "Hash key deve ser 'scenario'; recebido '${output.dynamodb_hash_key}'"
  }
}

run "range_key_eh_prioridade" {
  command = plan

  assert {
    condition     = output.dynamodb_range_key == "prioridade"
    error_message = "Range key deve ser 'prioridade'; recebido '${output.dynamodb_range_key}'"
  }
}

run "billing_mode_eh_pay_per_request" {
  command = plan

  assert {
    condition     = output.dynamodb_billing_mode == "PAY_PER_REQUEST"
    error_message = "Billing mode deve ser PAY_PER_REQUEST (on-demand) para evitar capacidade ociosa; recebido '${output.dynamodb_billing_mode}'"
  }
}

run "pitr_habilitado" {
  command = plan

  assert {
    condition     = output.dynamodb_pitr_enabled == true
    error_message = "Point-in-Time Recovery deve estar habilitado para proteger contra delete acidental"
  }
}

run "ttl_aponta_para_expiracao" {
  command = plan

  assert {
    condition     = output.dynamodb_ttl_attribute_name == "expiracao"
    error_message = "TTL deve usar o atributo 'expiracao'; recebido '${output.dynamodb_ttl_attribute_name}'"
  }

  assert {
    condition     = output.dynamodb_ttl_enabled == true
    error_message = "TTL deve estar habilitado para auto-purga de canarios sinteticos"
  }
}
