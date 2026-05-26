# Testes Cucumber-JS — infraenginepolicies

Testes BDD para a stack Terraform usando Cucumber-JS, Chai e AWS SDK v3.

## Pré-requisitos

- Node.js 18+
- Terraform 1.6+
- (opcional) Docker + LocalStack para testes de runtime

## Instalação

```bash
cd bdd
npm install
```

## Executar todos os testes

```bash
npm test
```

## Executar uma feature específica

```bash
npm run test:validation   # Apenas validação de sintaxe / variáveis
npm run test:dynamodb     # Apenas recursos DynamoDB
npm run test:secrets      # Apenas Secrets Manager
npm run test:ssm          # Apenas SSM Parameters
```

## Relatórios

Após execução:
- HTML: `bdd/reports/cucumber-report.html`
- JSON: `bdd/reports/cucumber-report.json`

## Estrutura

```
bdd/
├── cucumber.js              Configuração (paths, formatters, parallelism)
├── package.json             Dependências NPM
├── features/                Gherkin em pt-BR
│   ├── terraform-validation.feature
│   ├── dynamodb-resources.feature
│   ├── secrets-manager.feature
│   └── ssm-parameters.feature
├── step_definitions/        Implementação dos passos em JS
│   ├── terraform.steps.js
│   ├── dynamodb.steps.js
│   ├── secrets.steps.js
│   └── ssm.steps.js
└── support/
    ├── world.js             Custom World holder
    ├── hooks.js             Before/After
    ├── terraform-runner.js  Wrapper de terraform CLI via child_process
    └── aws-clients.js       Clients SDK para LocalStack
```

## Estratégia

Os testes operam em duas camadas:

**1. Plan-level** (não requer LocalStack)
A maioria dos cenários roda `terraform init -backend=false` + `terraform plan -out=tmp` + `terraform show -json tmp` e parseia o JSON resultante. Validamos a presença e configuração de recursos sem precisar aplicar.

**2. Apply-level** (opcional, requer LocalStack)
Para cenários marcados com `@apply`, sobe LocalStack via Docker, roda `terraform apply` e usa o AWS SDK para verificar recursos reais. Não está habilitado por default no `cucumber.js`.

## Exemplo de saída

```
$ npm test

> infraenginepolicies-bdd@1.0.0 test
> cucumber-js

............

12 scenarios (12 passed)
36 steps (36 passed)
0m18.532s
```
