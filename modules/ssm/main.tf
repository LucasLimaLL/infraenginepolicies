# ─────────────────────────────────────────────────────────────────────────────
# Module: ssm
#
# Stores behavioural configuration parameters consumed by Spring Boot
# at startup via AWS SDK v2 (ParameterStorePropertySource).
#
# Changing a value here takes effect on next application restart without
# any code deployment. The DynamoDB `timeout_ms` attribute on each rule
# takes precedence over the global default stored here.
#
# Parameters:
#   /{prefix}/default-timeout-ms         — Global HTTP timeout fallback (ms)
#   /{prefix}/app-port                   — Spring Boot server port
#   /{prefix}/spel-cache-max-size        — Caffeine L1 max compiled expressions
#   /{prefix}/spel-cache-expire-minutes  — Caffeine L1 expireAfterAccess TTL
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_ssm_parameter" "default_timeout_ms" {
  name        = "/${var.name_prefix}/default-timeout-ms"
  description = "Global fallback HTTP timeout (ms) for the rule executor. Overridden per rule by timeout_ms in DynamoDB. Must stay below P99 SLA of 500ms."
  type        = "String"
  value       = tostring(var.default_timeout_ms)

  tags = merge(var.tags, {
    Name      = "default-timeout-ms"
    Component = "engine-config"
  })
}

resource "aws_ssm_parameter" "app_port" {
  name        = "/${var.name_prefix}/app-port"
  description = "Spring Boot embedded server HTTP port."
  type        = "String"
  value       = tostring(var.app_port)

  tags = merge(var.tags, {
    Name      = "app-port"
    Component = "engine-config"
  })
}

resource "aws_ssm_parameter" "spel_cache_max_size" {
  name        = "/${var.name_prefix}/spel-cache-max-size"
  description = "Maximum number of pre-compiled SpEL Expression objects held in the Caffeine L1 cache per JVM instance."
  type        = "String"
  value       = tostring(var.spel_cache_max_size)

  tags = merge(var.tags, {
    Name      = "spel-cache-max-size"
    Component = "engine-config"
  })
}

resource "aws_ssm_parameter" "spel_cache_expire_minutes" {
  name        = "/${var.name_prefix}/spel-cache-expire-minutes"
  description = "expireAfterAccess TTL in minutes for the Caffeine L1 cache. Entries unused for this duration are evicted and reloaded from DynamoDB on next request."
  type        = "String"
  value       = tostring(var.spel_cache_expire_minutes)

  tags = merge(var.tags, {
    Name      = "spel-cache-expire-minutes"
    Component = "engine-config"
  })
}
