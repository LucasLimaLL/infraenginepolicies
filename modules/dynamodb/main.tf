# ─────────────────────────────────────────────────────────────────────────────
# Module: dynamodb
#
# Creates the physical shell of the `politicas` table.
# IMPORTANT: This module provisions ONLY the table structure (keys + billing).
# NO items, rules or business data are inserted from this repository.
# Item seeding is the exclusive responsibility of dataenginepolicies.
#
# Table design (Single Table Design):
#   PK  → scenario   (String) — tenant/partner identifier, routing key
#   SK  → prioridade (Number) — execution tier; DynamoDB returns items
#                               pre-sorted ascending, eliminating in-memory sort
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_dynamodb_table" "politicas" {
  name         = "politicas"
  billing_mode = "PAY_PER_REQUEST"   # On-Demand — pay per request, no provisioned capacity waste

  hash_key  = "scenario"
  range_key = "prioridade"

  attribute {
    name = "scenario"
    type = "S"
  }

  attribute {
    name = "prioridade"
    type = "N"
  }

  # Point-in-time recovery — protect against accidental bulk deletes
  point_in_time_recovery {
    enabled = true
  }

  # TTL attribute used by synthetic canary records to self-purge after 1h
  # The Java app sets `expiracao` (Unix epoch) when writing audit/canary items.
  ttl {
    attribute_name = "expiracao"
    enabled        = true
  }

  tags = merge(var.tags, {
    Name = "politicas"
    Role = "rules-store"
  })
}
