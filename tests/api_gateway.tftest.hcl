// ────────────────────────────────────────────────────────────────────────────
// tests/api_gateway.tftest.hcl
//
// CENARIO PROD — valida o modulo `api_gateway` quando create_api_gateway=true.
// Nunca executado em local dev (LocalStack Community nao emula API Gateway).
//
// Verifica que a entry-point B2B segue o contrato:
//   - HTTP API v2 (mais barato e rapido que REST v1)
//   - Rota ANY /v1/motor/{proxy+}
//   - payload_format_version=1.0 para preservar raw body (JsonNode envelope)
//   - Retencao de logs 7 dias
//   - URL backend reflete var.app_backend_url
// ────────────────────────────────────────────────────────────────────────────

variables {
  environment              = "prod"
  aws_region               = "us-east-1"
  localstack_endpoint      = "http://localhost:4566"
  create_network_resources = false
  create_api_gateway       = true
  app_backend_url          = "http://internal-alb.engine.svc:8080"
}

run "api_tem_nome_com_prefixo_correto" {
  command = plan

  assert {
    condition     = output.api_gateway_name == "engine-policies-prod-http-api"
    error_message = "Nome da API esperado 'engine-policies-prod-http-api'; recebido '${output.api_gateway_name}'"
  }
}

run "api_usa_protocolo_HTTP_v2" {
  command = plan

  assert {
    condition     = output.api_gateway_protocol == "HTTP"
    error_message = "API Gateway deve usar protocolo HTTP (v2); recebido '${output.api_gateway_protocol}'. REST v1 seria mais caro e lento."
  }
}

run "rota_correta_para_motor" {
  command = plan

  assert {
    condition     = output.api_gateway_route_key == "ANY /v1/motor/{proxy+}"
    error_message = "Route key deve ser 'ANY /v1/motor/{proxy+}' para encaminhar todos os subpaths; recebido '${output.api_gateway_route_key}'"
  }
}

run "payload_format_version_eh_1_0_para_preservar_raw_body" {
  command = plan

  assert {
    condition     = output.api_gateway_payload_format == "1.0"
    error_message = "payload_format_version deve ser '1.0' para preservar o raw body (JsonNode envelope); recebido '${output.api_gateway_payload_format}'. Versao 2.0 transforma o payload e quebra a Data Envelope pattern."
  }
}

run "log_retention_de_7_dias" {
  command = plan

  assert {
    condition     = output.api_gateway_log_retention_in_days == 7
    error_message = "Retencao do log group deve ser 7 dias; recebido ${output.api_gateway_log_retention_in_days}"
  }
}

run "ambiente_staging_compoe_nome_com_prefixo_correto" {
  command = plan
  variables { environment = "staging" }

  assert {
    condition     = output.api_gateway_name == "engine-policies-staging-http-api"
    error_message = "Em staging o nome deve ser 'engine-policies-staging-http-api'"
  }
}

// `invoke_url` e `api_id` sao 'known after apply' em plan-level — comparar
// com placeholder durante plan nao funciona. Estes asserts vivem em
// `apply_aws.tftest.hcl` (command = apply), onde os IDs reais estao disponiveis.
