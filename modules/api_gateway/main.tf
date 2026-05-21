# ─────────────────────────────────────────────────────────────────────────────
# Module: api_gateway
#
# HTTP API Gateway v2 — entry point for all B2B partner traffic.
#
# Routes:
#   ANY /v1/motor/{proxy+} → HTTP_PROXY → Spring Boot backend
#
# Key design decisions (per KS Section 2 & 10.A):
#   - HTTP API v2 is cheaper than REST API v1 and has lower latency.
#   - payload_format_version = "1.0" preserves the raw body as-is,
#     which is required for the Data Envelope pattern (JsonNode).
#   - The integration_uri uses {proxy} so any sub-path is forwarded.
#   - CORS is pre-configured for the X-Context-ID and X-Correlation-ID
#     headers used by the routing and MDC mechanisms.
#   - Access logs include integrationLatency to track backend P99 drift.
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_apigatewayv2_api" "motor" {
  name          = "${var.name_prefix}-http-api"
  protocol_type = "HTTP"
  description   = "HTTP API v2 — entry point for /v1/motor/* B2B traffic to the rules engine."

  cors_configuration {
    allow_headers  = ["Content-Type", "X-Context-ID", "X-Correlation-ID", "Authorization"]
    allow_methods  = ["POST", "GET", "OPTIONS"]
    allow_origins  = ["*"]
    expose_headers = ["X-Correlation-ID"]
    max_age        = 300
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-http-api"
  })
}

# ── Backend Integration ────────────────────────────────────────────────────────

resource "aws_apigatewayv2_integration" "motor_backend" {
  api_id             = aws_apigatewayv2_api.motor.id
  integration_type   = "HTTP_PROXY"
  integration_method = "ANY"

  # {proxy} is resolved by API Gateway to the matched path segment.
  # In local dev this points to host.docker.internal:8080.
  integration_uri = "${var.app_backend_url}/v1/motor/{proxy}"

  # 1.0 preserves raw body — required for the Jackson JsonNode Data Envelope.
  payload_format_version = "1.0"

  # Forward original client IP to the Spring Boot MDC filter.
  request_parameters = {
    "overwrite:header.X-Forwarded-For" = "$context.identity.sourceIp"
  }
}

# ── Route ─────────────────────────────────────────────────────────────────────

resource "aws_apigatewayv2_route" "motor_proxy" {
  api_id    = aws_apigatewayv2_api.motor.id
  route_key = "ANY /v1/motor/{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.motor_backend.id}"
}

# ── Default Stage (auto-deploy) ───────────────────────────────────────────────

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.motor.id
  name        = "$default"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw_access.arn

    format = jsonencode({
      requestId          = "$context.requestId"
      correlationId      = "$context.requestOverride.header.X-Correlation-ID"
      sourceIp           = "$context.identity.sourceIp"
      requestTime        = "$context.requestTime"
      httpMethod         = "$context.httpMethod"
      routeKey           = "$context.routeKey"
      status             = "$context.status"
      responseLength     = "$context.responseLength"
      integrationLatency = "$context.integrationLatency"
      responseLatency    = "$context.responseLatency"
    })
  }

  tags = var.tags
}

# ── CloudWatch Log Group ──────────────────────────────────────────────────────

resource "aws_cloudwatch_log_group" "api_gw_access" {
  name              = "/aws/api-gateway/${var.name_prefix}"
  retention_in_days = 7

  tags = merge(var.tags, {
    Name = "/aws/api-gateway/${var.name_prefix}"
  })
}
