// ────────────────────────────────────────────────────────────────────────────
// tests/feature_flags.tftest.hcl
//
// Valida o comportamento das feature flags `create_network_resources` e
// `create_api_gateway`. Em local dev (LocalStack Community nao emula VPC nem
// API Gateway) ambos devem estar OFF; em prod, ambos ON.
//
// Quando OFF, os outputs respectivos retornam "N/A (local dev)".
// Quando ON, retornam valores reais ou IDs/URLs do AWS provider.
// ────────────────────────────────────────────────────────────────────────────

variables {
  environment              = "local"
  aws_region               = "us-east-1"
  localstack_endpoint      = "http://localhost:4566"
  create_network_resources = false
  create_api_gateway       = false
}

run "sem_network_vpc_id_eh_NA" {
  command = plan

  assert {
    condition     = output.vpc_id == "N/A (local dev)"
    error_message = "Quando create_network_resources=false, vpc_id deve ser 'N/A (local dev)'; recebido '${output.vpc_id}'"
  }
}

run "sem_network_subnets_eh_vazio" {
  command = plan

  assert {
    condition     = length(output.public_subnet_ids) == 0
    error_message = "Quando create_network_resources=false, public_subnet_ids deve ser lista vazia"
  }

  assert {
    condition     = length(output.private_subnet_ids) == 0
    error_message = "Quando create_network_resources=false, private_subnet_ids deve ser lista vazia"
  }
}

run "sem_api_gateway_invoke_url_eh_NA" {
  command = plan

  assert {
    condition     = output.api_gateway_invoke_url == "N/A (local dev)"
    error_message = "Quando create_api_gateway=false, invoke_url deve ser 'N/A (local dev)'"
  }
}

run "sem_security_groups_fargate_redis_eh_NA" {
  command = plan

  assert {
    condition     = output.fargate_security_group_id == "N/A (local dev)"
    error_message = "Quando create_network_resources=false, fargate_sg deve ser 'N/A (local dev)'"
  }

  assert {
    condition     = output.redis_security_group_id == "N/A (local dev)"
    error_message = "Quando create_network_resources=false, redis_sg deve ser 'N/A (local dev)'"
  }
}
