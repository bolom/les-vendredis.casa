# Deployment runbook

## Preconditions

- Infomaniak app host is provisioned.
- PostgreSQL is provisioned and backup policy is active.
- `lesvendredis.casa` and `staging.lesvendredis.casa` DNS are ready.
- Kamal can read secrets from the 1Password vault `lesvendredis.casa` without interactive prompts.
- `KAMAL_1PASSWORD_ACCOUNT` is exported locally with the 1Password account identifier.
- Resend domain is verified; see `docs/resend-production.md`.

Required Kamal secrets:

- `DATABASE_URL`
- `RAILS_MASTER_KEY`
- `RESEND_API_KEY`
- `SECRET_KEY_BASE`
- `KAMAL_REGISTRY_PASSWORD`

1Password item layout:

- Vault: `lesvendredis.casa`
- Item `common`: `KAMAL_REGISTRY_PASSWORD`, `RAILS_MASTER_KEY`
- Item `production`: `DATABASE_URL`, `RESEND_API_KEY`, `SECRET_KEY_BASE`
- Item `staging`: `DATABASE_URL`, `RESEND_API_KEY`, `SECRET_KEY_BASE`

The Infomaniak experimental web server is configured in `.kamal/secrets-common` as `KAMAL_INFOMANIAK_HOST=185.143.102.224`.

Create the vault/items skeleton:

```bash
cd web
bin/setup-1password-kamal
```

The script creates empty fields only. Paste real secret values inside 1Password, not in the shell or repository.

Optional separate database URLs:

- `CACHE_DATABASE_URL`
- `QUEUE_DATABASE_URL`
- `CABLE_DATABASE_URL`

## Preflight

From the repo root:

```bash
web/bin/deploy-preflight
```

This checks ignored secret/data artifacts, builds Jekyll, and runs Rails CI.

## Staging

```bash
cd web
bin/kamal setup -d staging
bin/kamal deploy -d staging
bin/kamal app exec -d staging "bin/rails production:check"
bin/kamal app exec -d staging "bin/rails calendar_imports:sync_all"
bin/kamal app exec -d staging "bin/rails resend:smoke RAILS_ENV=staging RESEND_SMOKE_TO=delivered@resend.dev"
```

Verify:

- `/up`
- home FR/EN
- calendar availability
- booking inquiry form
- admin login and inquiry accept/decline
- Solid Queue worker
- GA4 DebugView and Search Console sitemap

## Production Cutover

Before cutover:

- Lower DNS TTL.
- Freeze changes on the old system.
- Export any manual booking/blocking state.
- Run final iCal sync after deploy.

Deploy:

```bash
cd web
bin/kamal setup
bin/kamal deploy
bin/kamal app exec "bin/rails production:check"
bin/kamal app exec "bin/rails calendar_imports:sync_all"
```

Post-cutover:

- Verify `/up`, public pages, booking inquiry, admin, jobs, email.
- Submit sitemap in Search Console if needed.
- Keep rollback path to the previous Jekyll deployment until monitoring is clean.

## Rollback

```bash
cd web
bin/kamal rollback
```

If DNS was changed and application rollback is not enough, restore the previous DNS target while TTL is still low.

## Restore Drill

Monthly:

- Restore latest PostgreSQL backup into a disposable database.
- Boot Rails against it with production-like env.
- Check admin dashboard, booking inquiries, availability blocks, calendar imports.
- Delete disposable restore target.
