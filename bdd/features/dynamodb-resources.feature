# language: pt
Funcionalidade: Recursos DynamoDB

  Cenário: Plan cria a tabela "politicas" com chaves corretas
    Dado que defino o environment como "local"
    Quando executo "terraform plan" em modo JSON
    Então o plan deve conter um recurso "aws_dynamodb_table"
    E a tabela planejada deve ter hash_key "scenario"
    E a tabela planejada deve ter range_key "prioridade"
    E a tabela planejada deve ter billing_mode "PAY_PER_REQUEST"
    E a tabela planejada deve ter point-in-time recovery habilitado

  Cenário: TTL configurado no atributo "expiracao"
    Dado que defino o environment como "local"
    Quando executo "terraform plan" em modo JSON
    Então o plan deve configurar TTL no atributo "expiracao"
