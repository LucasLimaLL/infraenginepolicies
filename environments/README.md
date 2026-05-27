# Inventories por ambiente (`environments/*.tfvars`)

Padrão Terraform equivalente ao **inventory file** do Ansible: um arquivo
`.tfvars` por ambiente, contendo apenas as variáveis que diferem entre
ambientes. O código Terraform (`.tf`) é único; o que muda é o input.

## Layout

```
environments/
├── local.tfvars     LocalStack — sem rede, sem API Gateway, Redis local
├── staging.tfvars   AWS real — 2 AZs, redis ElastiCache, timeout 450ms
├── prod.tfvars      AWS real — 3 AZs (multi-AZ), timeout 425ms (conservador)
└── README.md        este arquivo
```

## Uso

### Plan / Apply

```bash
# Local (LocalStack)
docker compose -f ../appenginepolicies/docker-compose.yml up -d localstack
terraform init -backend=false
terraform plan  -var-file=environments/local.tfvars
terraform apply -var-file=environments/local.tfvars

# Staging
export AWS_PROFILE=engine-staging
terraform init \
  -backend-config="bucket=$TF_BACKEND_BUCKET" \
  -backend-config="key=infraenginepolicies/staging/terraform.tfstate" \
  -backend-config="region=us-east-1" \
  -backend-config="dynamodb_table=$TF_BACKEND_LOCK_TABLE"
terraform plan  -var-file=environments/staging.tfvars
terraform apply -var-file=environments/staging.tfvars

# Prod (requer aprovação manual no GitHub Environment)
export AWS_PROFILE=engine-prod
terraform apply -var-file=environments/prod.tfvars
```

### Test

```bash
# Os testes têm seus próprios `variables {}` em cada .tftest.hcl, mas o -var-file
# serve como base para campos não sobrescritos pelo teste:
terraform test -var-file=environments/staging.tfvars
```

## O que NÃO está nestes arquivos

- **Segredos** (`redis_password`, tokens, chaves API): vêm de `AWS Secrets Manager`,
  variáveis de ambiente, ou `-var` no `terraform apply` — **nunca commitados**.
- **Credenciais AWS**: via `AWS_PROFILE`, OIDC ou IAM role da máquina/runner.
- **Backend state config**: via `-backend-config` no `terraform init` (porque
  bucket/key/lock-table dependem do ambiente do CI/CD).

## Regra de ouro

> Se uma variável muda **entre ambientes**, ela mora em `environments/<env>.tfvars`.
> Se ela muda **entre execuções do mesmo ambiente**, vem via `-var` ou env var.
> Se é **secreta**, nunca toca o disco em texto plano.

## Adicionar um novo ambiente

1. Criar `environments/<nome>.tfvars` (ex: `qa.tfvars`)
2. Adicionar `<nome>` à validação de `var.environment` em `variables.tf`
3. Adicionar `<nome>` ao filter dos `.tftest.hcl` relevantes se houver assertions
   específicas de ambiente
4. Criar GitHub Environment com mesmo nome se requer aprovação
