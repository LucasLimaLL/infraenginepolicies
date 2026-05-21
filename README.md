# infraenginepolicies

> **Responsabilidade:** Time de Plataforma / DevOps  
> **Camada:** Fundação AWS — conectividade, segurança e barramento de entrada

## Visão Geral

Este repositório gerencia toda a infraestrutura física da nuvem AWS que sustenta o **Motor Dinâmico de Cotação e Elegibilidade**. Nenhuma lógica de negócio ou dado de regras é injetado a partir daqui — apenas a casca física que os demais repositórios consomem.

## O que está provisionado aqui

| Recurso AWS | Papel |
|---|---|
| **VPC / Subnets / Security Groups** | Isolamento de rede dos containers ECS Fargate (subnets públicas e privadas) |
| **API Gateway (HTTP v1)** | Rotas de entrada `/v1/motor/*` com proxy reverso para a aplicação |
| **AWS Secrets Manager** | Tokens estáticos e credenciais do Redis/ElastiCache |
| **AWS SSM Parameter Store** | Parâmetros globais do Spring Boot (ex: `default-timeout-ms`) |
| **Amazon DynamoDB — tabela `politicas`** | Criação física da tabela com **Partition Key** (`scenario: String`) e **Sort Key** (`prioridade: Number`) — sem itens de negócio |

## O que NÃO está aqui

- Itens/regras do DynamoDB → repositório `dataenginepolicies`
- Código-fonte Java → repositório `appenginepolicies`

## Convenção de Branches

| Branch | Uso |
|---|---|
| `main` | Estado aprovado de produção |
| `develop` | Integração contínua |
| `feature/*` | Novas funcionalidades / recursos |

## Pré-requisitos

- Terraform >= 1.6
- AWS CLI v2 configurado com credenciais de deploy
- Acesso ao remote state (S3 + DynamoDB lock)

## Como aplicar

```bash
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

## Referência Arquitetural

Consulte a **Base de Conhecimento (KS) — Seção 10.A** para a especificação completa das responsabilidades deste repositório.
