terraform {
  required_version = ">= 1.10"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.27"
    }
    neon = {
      source  = "kislerdm/neon"
      version = "~> 0.18"
    }
  }

  # State lives in an R2 bucket created once by hand (see README). The account-specific endpoint
  # is passed at init time: terraform init -backend-config=backend.hcl
  backend "s3" {
    bucket                      = "cairn-terraform-state"
    key                         = "staging/terraform.tfstate"
    region                      = "auto"
    use_path_style              = true
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_s3_checksum            = true
  }
}

# Credentials come from the environment: CLOUDFLARE_API_TOKEN and NEON_API_KEY.
provider "cloudflare" {}
provider "neon" {}

variable "cloudflare_account_id" {
  type = string
}

locals {
  environment = "staging"
}

module "storage" {
  source      = "../../modules/storage"
  account_id  = var.cloudflare_account_id
  environment = local.environment
}

module "database" {
  source      = "../../modules/database"
  environment = local.environment
}

output "journal_bucket" {
  value = module.storage.journal_bucket
}

output "shares_bucket" {
  value = module.storage.shares_bucket
}

output "database_url" {
  value     = module.database.database_url
  sensitive = true
}
