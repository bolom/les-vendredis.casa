# Deployment runbook

## Preconditions

- Infomaniak app host is provisioned.
- PostgreSQL is provisioned and backup policy is active.
- `lesvendredis.casa` DNS is ready.
- Kamal can read secrets from the 1Password vault `lesvendredis.casa` without interactive prompts.
- `KAMAL_1PASSWORD_ACCOUNT` is exported locally with the 1Password account identifier.
- Resend domain is verified; see `docs/resend-production.md`.

Required Kamal secrets:

- `RAILS_MASTER_KEY`
- `KAMAL_REGISTRY_PASSWORD`

1Password item layout:

- Vault: `lesvendredis.casa`
- Item `common`: `KAMAL_REGISTRY_PASSWORD`
- Item `production`: `RAILS_MASTER_KEY`

Database, calendar, Resend and Rails application secrets are stored in
`config/credentials.yml.enc`, not as separate 1Password fields.

The Infomaniak experimental web server is configured in `.kamal/secrets-common` as `KAMAL_INFOMANIAK_HOST=185.143.102.224`.

Create the vault/items skeleton:

```bash
cd web
bin/setup-1password-kamal
```

The script creates empty fields only. Paste real secret values inside 1Password, not in the shell or repository.

## Preflight

From the repo root:

```bash
web/bin/deploy-preflight
```

This checks ignored secret/data artifacts, builds Jekyll, and runs Rails CI.

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
