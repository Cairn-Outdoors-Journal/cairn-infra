# R2 buckets for one environment.
#
# - journal: encrypted journal blobs (change packs, snapshots, media). Private; the phone reads and
#   writes through short-lived pre-signed URLs issued by cairn-api. Cairn cannot read the contents.
# - shares: rendered pages a person chose to share. Served to the share-link viewer.

terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
    }
  }
}

variable "account_id" {
  description = "Cloudflare account that owns the buckets."
  type        = string
}

variable "environment" {
  description = "Environment name, used in bucket names (staging or prod)."
  type        = string
}

resource "cloudflare_r2_bucket" "journal" {
  account_id = var.account_id
  name       = "cairn-${var.environment}-journal"
}

resource "cloudflare_r2_bucket" "shares" {
  account_id = var.account_id
  name       = "cairn-${var.environment}-shares"
}

output "journal_bucket" {
  value = cloudflare_r2_bucket.journal.name
}

output "shares_bucket" {
  value = cloudflare_r2_bucket.shares.name
}
