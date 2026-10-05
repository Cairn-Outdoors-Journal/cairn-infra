#!/usr/bin/env bash
# Create the Fly.io app for an environment (if missing) and copy Terraform outputs into its secrets.
#
# Fly.io's Terraform provider is archived, so Fly apps are managed with flyctl instead.
# Requires: flyctl (logged in), terraform, and an initialised envs/<environment> directory.
#
# Usage: [FLY_ORG=<org-slug>] scripts/sync-fly-secrets.sh staging|prod

set -euo pipefail

environment="${1:-}"
if [[ "$environment" != "staging" && "$environment" != "prod" ]]; then
  echo "Usage: $0 staging|prod" >&2
  exit 1
fi

app="cairn-api-${environment}"
env_dir="$(cd "$(dirname "$0")/.." && pwd)/envs/${environment}"

if ! fly apps list --json | grep -q "\"Name\": *\"${app}\""; then
  echo "Creating Fly app ${app}"
  fly apps create "$app" --org "${FLY_ORG:-personal}"
fi

database_url="$(terraform -chdir="$env_dir" output -raw database_url)"
journal_bucket="$(terraform -chdir="$env_dir" output -raw journal_bucket)"
shares_bucket="$(terraform -chdir="$env_dir" output -raw shares_bucket)"

# --stage: secrets take effect on the next deploy rather than restarting machines now.
fly secrets set --app "$app" --stage \
  "CAIRN_DATABASE_URL=${database_url}" \
  "CAIRN_JOURNAL_BUCKET=${journal_bucket}" \
  "CAIRN_SHARES_BUCKET=${shares_bucket}" >/dev/null

echo "Updated secrets for ${app}. They apply on the next deploy."
