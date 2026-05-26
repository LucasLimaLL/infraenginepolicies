# language: pt
Funcionalidade: Secrets Manager

  Cenário: Plan cria secret de credenciais Redis
    Dado que defino o environment como "local"
    Quando executo "terraform plan" em modo JSON
    Então o plan deve conter um recurso "aws_secretsmanager_secret" com sufixo "redis-credentials"
    E o secret deve ter recovery_window_in_days igual a 7

  Cenário: Plan cria secret de tokens da aplicação
    Dado que defino o environment como "local"
    Quando executo "terraform plan" em modo JSON
    Então o plan deve conter um recurso "aws_secretsmanager_secret" com sufixo "app-tokens"
