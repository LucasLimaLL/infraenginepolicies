# Testes Integrados Terraform (`terraform test`)

Suite de testes nativa do Terraform 1.6+ que valida a stack de infraestrutura
contra as variáveis de input, garantindo:

- Cada recurso criado reflete **exatamente** os valores passados como variável.
- **Nenhum default silencioso**: se o root sobrescreve uma variável do módulo,
  o teste confirma que a sobrescrita propagou.
- Regras de validação do `variables.tf` **rejeitam** valores inválidos antes do
  apply (`expect_failures`).
- Saída pass/fail clara por `run` block com mensagem de erro descritiva.

## Layout

```
infraenginepolicies/
├── tests/
│   ├── variables.tftest.hcl       Validações: environment ∈ {local,staging,prod}, timeout 1-499
│   ├── dynamodb.tftest.hcl        Tabela `politicas` (PK, SK, billing, PITR, TTL)
│   ├── secrets.tftest.hcl         Nomes prefixados, recovery_window=7
│   ├── ssm.tftest.hcl             4 parâmetros, valores correspondem à variável
│   ├── feature_flags.tftest.hcl   Flags OFF → outputs "N/A" (local dev)
│   ├── name_prefix.tftest.hcl     `${project}-${environment}` em todos os recursos
│   ├── networking.tftest.hcl      CENÁRIO PROD: VPC, subnets, SGs (flags ON)
│   ├── api_gateway.tftest.hcl     CENÁRIO PROD: HTTP API v2, rota, payload format
│   ├── apply_localstack.tftest.hcl  E2E LocalStack (DynamoDB+Secrets+SSM apenas)
│   ├── apply_aws.tftest.hcl       E2E AWS REAL (stack inteira, opt-in)
│   └── README.md
```

## Matriz de cobertura por ambiente

| Teste | Local (LocalStack) | Staging/Prod (AWS) | Tipo |
|-------|:------------------:|:------------------:|------|
| `variables.tftest.hcl` | ✅ | ✅ | plan |
| `dynamodb.tftest.hcl` | ✅ | ✅ | plan |
| `secrets.tftest.hcl` | ✅ | ✅ | plan |
| `ssm.tftest.hcl` | ✅ | ✅ | plan |
| `feature_flags.tftest.hcl` | ✅ (flags OFF) | — | plan |
| `name_prefix.tftest.hcl` | ✅ | ✅ | plan |
| `networking.tftest.hcl` | — (LocalStack não emula VPC) | ✅ (flags ON) | plan |
| `api_gateway.tftest.hcl` | — (LocalStack não emula APIGw) | ✅ (flags ON) | plan |
| `apply_localstack.tftest.hcl` | ✅ (apply real) | — | apply |
| `apply_aws.tftest.hcl` | — | ✅ (apply real, opt-in) | apply |

Os testes plan-level dos módulos `networking` e `api_gateway` rodam mesmo sem
AWS — eles materializam o plan com as feature flags ligadas e validam que cada
atributo do resource reflete o input. O cenário **apply real contra AWS** está
isolado em `apply_aws.tftest.hcl` e exige credenciais — não roda em CI por
padrão.

## Pré-requisitos

| Ferramenta | Versão mínima | Por quê |
|-----------|--------------|---------|
| Terraform | 1.6+ (testado em 1.7.5) | `tftest.hcl` introduzido em 1.6 |
| Docker (opcional) | qualquer | Apenas para `apply_localstack.tftest.hcl` |
| LocalStack (opcional) | community 3+ | Apenas para o E2E |

## Como rodar

### 1. Suite estática (rápida — não requer AWS)

Apenas plan; valida validações de variáveis, outputs computados e comportamento de feature flags. Roda em ~5 segundos:

```bash
# da raiz do infraenginepolicies/
terraform init -backend=false
terraform test \
  -filter=tests/variables.tftest.hcl \
  -filter=tests/dynamodb.tftest.hcl \
  -filter=tests/secrets.tftest.hcl \
  -filter=tests/ssm.tftest.hcl \
  -filter=tests/feature_flags.tftest.hcl \
  -filter=tests/name_prefix.tftest.hcl
```

Ou simplesmente:

```bash
terraform test
```

(executa **todos** os `.tftest.hcl` em `tests/`, incluindo `apply_localstack` —
que falhará se LocalStack não estiver rodando).

### 2. Cenário local com apply real em LocalStack

```bash
# Sobe LocalStack via docker-compose do appenginepolicies
docker compose -f ../appenginepolicies/docker-compose.yml up -d localstack

# Aguarda LocalStack ficar healthy
until curl -s http://localhost:4566/_localstack/health | grep -q '"running"'; do sleep 1; done

# Executa todos os tests EXCETO apply_aws (que requer AWS real)
terraform init -backend=false
terraform test  # 'apply_aws.tftest.hcl' falha aqui — esperado
```

### 3. Cenário prod com apply real em AWS (manual, opt-in)

```bash
# Configurar credenciais AWS (perfil ou OIDC)
export AWS_PROFILE=engine-staging

# Init com backend remoto S3 + DynamoDB lock
terraform init \
  -backend-config="bucket=$TF_BACKEND_BUCKET" \
  -backend-config="key=infraenginepolicies/test/terraform.tfstate" \
  -backend-config="region=us-east-1" \
  -backend-config="dynamodb_table=$TF_BACKEND_LOCK_TABLE"

# Roda APENAS o teste de apply em AWS real (cria + destroi recursos)
terraform test -filter=tests/apply_aws.tftest.hcl
```

⚠️ **Atenção**: `apply_aws.tftest.hcl` cria recursos AWS **reais**
(VPC, API Gateway, DynamoDB, Secrets, SSM) e os destrói ao fim do `run`. Custa
centavos por execução. Não deve rodar em PRs de CI sem aprovação manual.

Após o `apply` test, os recursos ficam em LocalStack — para inspecionar via AWS CLI:

```bash
aws --endpoint-url=http://localhost:4566 dynamodb describe-table --table-name politicas
aws --endpoint-url=http://localhost:4566 secretsmanager list-secrets
aws --endpoint-url=http://localhost:4566 ssm get-parameter --name /engine-policies-local/default-timeout-ms
```

## Interpretando a saída

Saída típica de um `terraform test`:

```
tests/dynamodb.tftest.hcl... in progress
  run "tabela_tem_nome_fixo_politicas"... pass
  run "hash_key_eh_scenario"... pass
  run "range_key_eh_prioridade"... pass
  run "billing_mode_eh_pay_per_request"... pass
  run "pitr_habilitado"... pass
  run "ttl_aponta_para_expiracao"... pass
tests/dynamodb.tftest.hcl... tearing down
tests/dynamodb.tftest.hcl... pass

Success! 6 passed, 0 failed.
```

Em falha (exemplo realístico de mudança acidental de billing_mode):

```
  run "billing_mode_eh_pay_per_request"... fail

  Error: Test assertion failed

    on tests/dynamodb.tftest.hcl line 60, in run "billing_mode_eh_pay_per_request":
       60:     condition     = output.dynamodb_billing_mode == "PAY_PER_REQUEST"
        ├────────────────
        │ output.dynamodb_billing_mode is "PROVISIONED"

  Billing mode deve ser PAY_PER_REQUEST (on-demand) para evitar capacidade
  ociosa; recebido 'PROVISIONED'
```

A mensagem `error_message` do `assert` é mostrada literalmente — por isso elas
seguem o padrão "esperado X; recebido Y" para diagnóstico imediato.

## Por que `terraform test` (nativo) e não Terratest?

| Critério | `terraform test` | Terratest |
|----------|------------------|-----------|
| Linguagem | HCL (zero novo runtime) | Go |
| Setup | Nenhum — já vem no CLI | Instalar Go + dependências |
| Acesso ao estado | Direto via outputs e variáveis | Via `terraform output -json` parseado |
| Asserts contra plan | ✅ nativo | Indireto (parse de plan -json) |
| Asserts contra apply real | ✅ nativo via `command = apply` | ✅ executa `terraform apply` |
| Validação de variables.tf | ✅ `expect_failures = [var.x]` | Manual via comparação de erro |
| Cobertura no time | Qualquer dev de IaC | Requer expertise Go |

Para este projeto, todos os recursos AWS são "shape-checkáveis" via outputs;
testes Go via Terratest adicionariam superfície sem benefício diferencial.
Mantemos o BDD-JS em `bdd/` para o cenário de **plan estrutural** (parse de
plan JSON para descobrir recursos) — o `terraform test` complementa cobrindo
**fidelidade input→recurso** e **ciclo apply real**.

## Integração CI/CD

Adicionar à workflow GitHub Actions (`.github/workflows/terraform-ci.yml`):

```yaml
- name: Terraform Test (plan-level)
  run: |
    terraform init -backend=false
    terraform test -verbose \
      -filter=tests/variables.tftest.hcl \
      -filter=tests/dynamodb.tftest.hcl \
      -filter=tests/secrets.tftest.hcl \
      -filter=tests/ssm.tftest.hcl \
      -filter=tests/feature_flags.tftest.hcl \
      -filter=tests/name_prefix.tftest.hcl
```

O `apply_localstack.tftest.hcl` fica fora do CI por padrão (requer LocalStack
container) — pode ser habilitado em um job opcional com `services: localstack`
no GitHub Actions.
