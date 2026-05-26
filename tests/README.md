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
│   ├── feature_flags.tftest.hcl   create_network_resources / create_api_gateway
│   ├── name_prefix.tftest.hcl     `${project}-${environment}` em todos os recursos
│   ├── apply_localstack.tftest.hcl  E2E real com `command = apply` contra LocalStack
│   └── README.md
```

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

### 2. Suite completa (com apply real em LocalStack)

```bash
# Sobe LocalStack via docker-compose do appenginepolicies
docker compose -f ../appenginepolicies/docker-compose.yml up -d localstack

# Aguarda LocalStack ficar healthy
until curl -s http://localhost:4566/_localstack/health | grep -q '"running"'; do sleep 1; done

# Executa toda a suite
terraform init -backend=false
terraform test
```

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
