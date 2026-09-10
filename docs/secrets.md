# Secret management — source of truth and rotation

> **Decision documented below is to be confirmed by Bolo** (issue #38).
> The practice below is what the repository does today, written down
> consistently for the first time.

## Architecture (one store per use, no hidden duplication)

| Secret | Source of truth | Mirrored to | Used by |
|---|---|---|---|
| Rails app secrets (`SECRET_KEY_BASE`, `DATABASE_URL`, `RESEND_API_KEY`, GlitchTip DSN, calendar URLs, x402 settings) | `config/credentials.yml.enc` | — | Rails runtime (production) |
| `RAILS_MASTER_KEY` | 1Password vault `lesvendredis.casa`, item `production` | GitHub Actions Secret (deploy CI) | Kamal (unlocks `credentials.yml.enc`) |
| `POSTGRES_PASSWORD` | 1Password vault `lesvendredis.casa`, item `production` | GitHub Actions Secret (deploy CI) | Postgres accessory + `DATABASE_URL` build in `.kamal/secrets` |
| `KAMAL_REGISTRY_PASSWORD` | 1Password vault `Compass Deploy` (Docker Hub access token, shared with the Compass deployments; fetched by `.kamal/secrets-common`) | GitHub Actions Secret (deploy CI) | Kamal image push/pull |
| `SSH_PRIVATE_KEY` | Never in 1Password (keypair owned by GitHub Actions) | GitHub Actions Secret only | Deploy CI → VPS |

Why the mirrors exist: the automated deploy runs on GitHub Actions, which has
no 1Password CLI session. The three values it needs (`RAILS_MASTER_KEY`,
`POSTGRES_PASSWORD`, `KAMAL_REGISTRY_PASSWORD`) are therefore mirrored from
1Password into GitHub Actions Secrets. **1Password stays the authority: any
rotation happens there first, then is copied to the GitHub mirror.**

Local/interactive deploys use `.kamal/secrets*` (dotenv command substitution
into 1Password) — see `bin/setup-1password-kamal`, which creates empty fields
only; real values are pasted in 1Password, never in the shell or repository.

## Rotation procedure (testable checklist)

1. Rotate the value in 1Password vault `lesvendredis.casa`
   (`common` for the registry, `production` for master key / Postgres).
2. Update the GitHub Actions mirror:
   `gh secret set <NAME> --repo bolom/les-vendredis.casa` (paste the new value;
   it is never echoed).
3. Update `config/credentials.yml.enc` if the rotated secret feeds the Rails
   runtime (`bin/rails credentials:edit`).
4. Verify without deploying:
   - `gh secret list --repo bolom/les-vendredis.casa` — names present, and
     `updatedAt` shows the fresh rotation.
   - `bin/kamal secrets print`-equivalent locally (Kamal resolves the
     dotenv/1Password chain without contacting the server).
5. Verify after deploy (deliberate, from the Deploy workflow's
   `workflow_dispatch` — the CI gate still applies):
   - Deploy workflow green, then
     `curl -fsS https://lesvendredis.casa/up`.
   - `bin/kamal app exec "bin/rails production:check"`.

## Rules

- No raw secret values in Git, logs, issues, or PRs — names only.
- One store per secret; every duplication is listed in the table above and
  mirrored deliberately, never silently.
- The deploy CI requires exactly: `SSH_PRIVATE_KEY`, `RAILS_MASTER_KEY`,
  `POSTGRES_PASSWORD`, `KAMAL_REGISTRY_PASSWORD`
  (see `.github/workflows/deploy.yml`).
