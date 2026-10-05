# cairn-infra

Infrastructure for Cairn's cloud side, as [OpenTofu](https://opentofu.org) code. See
[ARCHITECTURE.md](https://github.com/Cairn-Outdoors-Journal/cairn-product-hub/blob/main/ARCHITECTURE.md)
in the product hub for how the pieces fit together.

| Piece | Managed by | What it is |
|---|---|---|
| R2 buckets | OpenTofu (`modules/storage`) | `cairn-<env>-journal`: encrypted journal blobs. `cairn-<env>-shares`: pages people chose to share. |
| Postgres | OpenTofu (`modules/database`) | A Neon project per environment: accounts, sync cursors, entitlements. Never journal content. |
| API hosting | flyctl (`scripts/sync-fly-secrets.sh`) | The Fly.io apps `cairn-api-staging` and `cairn-api-prod`. Fly's Terraform provider is archived, so these are created and configured with flyctl. |
| DNS | not yet | Added once Cairn has a domain. |

Two environments, `envs/staging` and `envs/prod`, use the same modules with separate state.

## First-time setup

1. **Accounts and tokens.** You need:
   - a Cloudflare API token with R2 edit rights, set as `CLOUDFLARE_API_TOKEN`;
   - a Neon API key, set as `NEON_API_KEY`;
   - R2 access keys for the state bucket, set as `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`;
   - flyctl, logged in.
2. **State bucket.** Create the R2 bucket `cairn-tofu-state` once, by hand, in the Cloudflare dashboard.
   OpenTofu keeps its state there, so this bucket can't be managed by OpenTofu itself.
3. **Per environment:**
   ```sh
   cd envs/staging
   cp backend.hcl.example backend.hcl            # add your Cloudflare account ID
   cp terraform.tfvars.example terraform.tfvars  # add your Cloudflare account ID
   tofu init -backend-config=backend.hcl
   tofu plan
   tofu apply
   ../../scripts/sync-fly-secrets.sh staging     # creates the Fly app, copies outputs into its secrets
   ```

`backend.hcl`, `terraform.tfvars` and state files are git-ignored.

## Pipelines

- **CI** ([ci.yml](.github/workflows/ci.yml)), on every pull request and on `main`: format check,
  and `tofu validate` for staging and prod.
- **Plan on pull request, apply on merge** (with manual approval for prod) will be added once the
  Cloudflare and Neon tokens are stored as GitHub secrets.
