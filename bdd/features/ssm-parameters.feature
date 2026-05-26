# language: pt
Funcionalidade: SSM Parameter Store

  Cenário: Plan cria parâmetro de timeout global
    Dado que defino o environment como "local"
    Quando executo "terraform plan" em modo JSON
    Então o plan deve conter um parâmetro SSM com nome contendo "default-timeout-ms"
    E o valor do parâmetro deve estar entre 1 e 499

  Cenário: Plan cria parâmetro de porta da aplicação
    Dado que defino o environment como "local"
    Quando executo "terraform plan" em modo JSON
    Então o plan deve conter um parâmetro SSM com nome contendo "app-port"

  Cenário: Plan cria parâmetros de configuração do cache SpEL
    Dado que defino o environment como "local"
    Quando executo "terraform plan" em modo JSON
    Então o plan deve conter um parâmetro SSM com nome contendo "spel-cache-max-size"
    E o plan deve conter um parâmetro SSM com nome contendo "spel-cache-expire-minutes"
