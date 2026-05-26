// ────────────────────────────────────────────────────────────────────────────
// tests/networking.tftest.hcl
//
// CENARIO PROD — valida o modulo `networking` quando
// create_network_resources=true (NUNCA executado em local dev / LocalStack
// Community, que nao emula VPC/EC2/SG).
//
// Roda em `command = plan` — nao requer AWS real, mas precisa de provider
// configurado. Aqui mantemos `localstack_endpoint` para que o provider pule
// validacao de credenciais; o plan apenas materializa a estrutura e os
// asserts comparam atributos com as variaveis de input.
//
// Para teste apply contra AWS real, ver: apply_aws.tftest.hcl
// ────────────────────────────────────────────────────────────────────────────

variables {
  environment              = "prod"
  aws_region               = "us-east-1"
  localstack_endpoint      = "http://localhost:4566" // bypass credential validation no plan
  create_network_resources = true
  create_api_gateway       = false
  vpc_cidr                 = "10.0.0.0/16"
  availability_zones       = ["us-east-1a", "us-east-1b"]
}

run "vpc_cidr_corresponde_ao_input" {
  command = plan

  assert {
    condition     = output.vpc_cidr_block == "10.0.0.0/16"
    error_message = "VPC CIDR deve refletir var.vpc_cidr=10.0.0.0/16; recebido '${output.vpc_cidr_block}'"
  }
}

run "vpc_cidr_customizado_propagou" {
  command = plan
  variables { vpc_cidr = "172.31.0.0/16" }

  assert {
    condition     = output.vpc_cidr_block == "172.31.0.0/16"
    error_message = "Quando var.vpc_cidr=172.31.0.0/16, VPC deve usar este CIDR; recebido '${output.vpc_cidr_block}'"
  }
}

run "uma_subnet_publica_por_az" {
  command = plan

  assert {
    condition     = length(output.public_subnet_cidrs) == 2
    error_message = "Devem existir 2 subnets publicas (uma por AZ); encontradas ${length(output.public_subnet_cidrs)}"
  }
}

run "uma_subnet_privada_por_az" {
  command = plan

  assert {
    condition     = length(output.private_subnet_cidrs) == 2
    error_message = "Devem existir 2 subnets privadas (uma por AZ); encontradas ${length(output.private_subnet_cidrs)}"
  }
}

run "subnets_seguem_convencao_publica_baixa_privada_alta" {
  command = plan

  // cidrsubnet(10.0.0.0/16, 8, count.index + 1) -> 10.0.1.0/24, 10.0.2.0/24
  assert {
    condition     = contains(output.public_subnet_cidrs, "10.0.1.0/24") && contains(output.public_subnet_cidrs, "10.0.2.0/24")
    error_message = "Subnets publicas devem ser 10.0.1.0/24 e 10.0.2.0/24"
  }

  // cidrsubnet(10.0.0.0/16, 8, count.index + 10) -> 10.0.10.0/24, 10.0.11.0/24
  assert {
    condition     = contains(output.private_subnet_cidrs, "10.0.10.0/24") && contains(output.private_subnet_cidrs, "10.0.11.0/24")
    error_message = "Subnets privadas devem ser 10.0.10.0/24 e 10.0.11.0/24 (offset 10 + count.index via cidrsubnet)"
  }
}

run "tres_azs_geram_tres_subnets_publicas_e_privadas" {
  command = plan
  variables { availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"] }

  assert {
    condition     = length(output.public_subnet_cidrs) == 3 && length(output.private_subnet_cidrs) == 3
    error_message = "3 AZs devem produzir 3 subnets publicas e 3 privadas"
  }
}

run "fargate_sg_permite_apenas_porta_8080_inbound" {
  command = plan

  assert {
    condition     = length(output.fargate_ingress_ports) == 1 && output.fargate_ingress_ports[0] == 8080
    error_message = "Fargate SG deve ter apenas 1 regra inbound na porta 8080; encontradas portas ${join(",", [for p in output.fargate_ingress_ports : tostring(p)])}"
  }
}

run "redis_sg_NAO_aceita_trafego_da_internet" {
  command = plan

  // O ingress do Redis SG deve referenciar APENAS security_groups (do Fargate)
  // e NUNCA cidr_blocks. Expor Redis na internet = vazamento crítico.
  assert {
    condition     = length(output.redis_ingress_cidr_blocks) == 0
    error_message = "VIOLACAO DE SEGURANCA: Redis SG nao pode aceitar CIDR blocks no ingress; encontrados: ${join(",", output.redis_ingress_cidr_blocks)}"
  }
}

// O assert `length(output.redis_ingress_source_sg_ids) >= 1` nao funciona em
// plan-level porque o ID do Fargate SG ainda nao foi computado.
// Esta validacao vive em `apply_aws.tftest.hcl` (command = apply).
