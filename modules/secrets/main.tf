# ─────────────────────────────────────────────────────────────────────────────
# Module: secrets
#
# Stores sensitive runtime credentials in AWS Secrets Manager.
# The Spring Boot app reads these at startup via the AWS SDK v2.
#
# Secrets created:
#   {prefix}/redis-credentials  → Redis host, port and AUTH password
#   {prefix}/app-tokens         → Static B2B partner API tokens
# ─────────────────────────────────────────────────────────────────────────────

# ── Redis Credentials ─────────────────────────────────────────────────────────

resource "aws_secretsmanager_secret" "redis_credentials" {
  name        = "${var.name_prefix}/redis-credentials"
  description = "ElastiCache Redis connection credentials (host, port, password) for L2 Pub/Sub cache."

  # Allow recovery within 7 days before permanent deletion
  recovery_window_in_days = 7

  tags = merge(var.tags, {
    Name      = "${var.name_prefix}/redis-credentials"
    Component = "cache-l2"
  })
}

resource "aws_secretsmanager_secret_version" "redis_credentials" {
  secret_id = aws_secretsmanager_secret.redis_credentials.id

  secret_string = jsonencode({
    host     = var.redis_host
    port     = var.redis_port
    password = var.redis_password
  })
}

# ── B2B API Tokens ─────────────────────────────────────────────────────────────

resource "aws_secretsmanager_secret" "app_tokens" {
  name        = "${var.name_prefix}/app-tokens"
  description = "Static API tokens for B2B partner authentication at the engine gateway."

  recovery_window_in_days = 7

  tags = merge(var.tags, {
    Name      = "${var.name_prefix}/app-tokens"
    Component = "auth"
  })
}

resource "aws_secretsmanager_secret_version" "app_tokens" {
  secret_id = aws_secretsmanager_secret.app_tokens.id

  # Placeholder value — rotate immediately after first deploy via console or CLI.
  # Do NOT use this token in production without rotation.
  secret_string = jsonencode({
    note            = "ROTATE_IMMEDIATELY_AFTER_DEPLOY"
    api_token_v1    = "REPLACE_ME"
  })
}
