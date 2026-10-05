# A Neon Postgres project for one environment: accounts, devices, sync cursors and
# entitlements. Never journal content.

terraform {
  required_providers {
    neon = {
      source = "kislerdm/neon"
    }
  }
}

variable "environment" {
  description = "Environment name (staging or prod)."
  type        = string
}

variable "region" {
  description = "Neon region. Pick the one closest to the Fly.io region the API runs in."
  type        = string
  default     = "aws-us-west-2"
}

resource "neon_project" "this" {
  name       = "cairn-${var.environment}"
  region_id  = var.region
  pg_version = 17

  branch {
    name          = "main"
    database_name = "cairn"
    role_name     = "cairn_api"
  }
}

output "database_url" {
  description = "Connection URL for cairn-api (CAIRN_DATABASE_URL)."
  value       = neon_project.this.connection_uri
  sensitive   = true
}
