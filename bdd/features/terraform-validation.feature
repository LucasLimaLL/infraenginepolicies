# language: pt
Funcionalidade: Validação do código Terraform e variáveis

  Como engenheiro de infraestrutura
  Quero validar a sintaxe e as constraints de variáveis
  Para garantir que apenas configurações válidas sejam aplicadas

  Cenário: Sintaxe Terraform válida
    Quando executo "terraform validate"
    Então o comando deve ter sucesso
    E a saída deve indicar configuração válida

  Cenário: Variável "environment" rejeita valor inválido
    Dado que defino a variável "environment" como "qa"
    Quando executo "terraform plan"
    Então o comando deve falhar
    E a saída deve conter "environment"

  Cenário: Variável "default_timeout_ms" rejeita valor acima do limite SLA
    Dado que defino a variável "default_timeout_ms" como "600"
    Quando executo "terraform plan"
    Então o comando deve falhar
    E a saída deve conter "500"

  Esquema do Cenário: Variável "environment" aceita valores permitidos
    Dado que defino a variável "environment" como "<env>"
    Quando executo "terraform plan"
    Então o plan deve ser gerado sem erros de validação

    Exemplos:
      | env     |
      | local   |
      | staging |
      | prod    |
