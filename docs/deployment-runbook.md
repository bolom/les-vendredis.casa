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
bin/setup-1password-kamal
```

The script creates empty fields only. Paste real secret values inside 1Password, not in the shell or repository.

## Preflight

From the repo root:

```bash
bin/deploy-preflight
```

This checks ignored secret/data artifacts and runs the Rails CI/preflight path.

## Staging (pre-production host)

`staging.lesvendredis.casa` serves the SAME production Rails environment on
the Infomaniak VPS; it is a preview of the app before the public cutover.
Kamal destination `staging` (`config/deploy.staging.yml`) isolates the service
name, volumes and database accessory: `DATABASE_URL` points the app at the
staging Postgres container instead of the credentials URL, and
`GA_MEASUREMENT_ID` is blank so staging does not pollute analytics. Booking
emails are real (`hello@lesvendredis.casa` is the verified sender), so use
your own address when testing the booking flow.

One-time setup:

- In Cloudflare, the `staging` A record points at `185.143.102.224` and is
  **DNS only** (grey cloud) so kamal-proxy can obtain its own Let's Encrypt
  certificate.
- Item `production` (vault `lesvendredis.casa`): field `RAILS_MASTER_KEY`
  must contain the value of `config/master.key`.
- Item `staging`: field `POSTGRES_PASSWORD` must contain the staging database
  password (the one baked into the staging `DATABASE_URL`).
- `bin/setup-1password-kamal` creates empty fields only; paste values in
  1Password, never in the repository.

Deploy:

```bash
bin/kamal setup -d staging   # first deploy: proxy, Postgres accessory, app
bin/kamal deploy -d staging
```

Verify:

```bash
curl -fsS https://staging.lesvendredis.casa/up
bin/kamal app exec "bin/rails production:check" -d staging
bin/kamal logs -d staging
```

Rollback:

```bash
bin/kamal rollback -d staging <version>
```

The staging Postgres lives in the `les-vendredis-staging-db` container with
volume `les_vendredis_staging_db`. To wipe staging data and start fresh,
remove the volume, the accessory and run `bin/kamal setup -d staging` again.

## Production Cutover

Before cutover:

- Lower DNS TTL.
- Freeze changes on the old system.
- Export any manual booking/blocking state.
- Run final iCal sync after deploy.

Deploy:

```bash
bin/kamal setup
bin/kamal deploy
bin/kamal app exec "bin/rails production:check"
bin/kamal app exec "bin/rails calendar_imports:sync_all"
```

Post-cutover:

- Verify `/up`, public pages, booking inquiry, admin, jobs, email.
- Submit sitemap in Search Console if needed.
- Keep rollback path to the previous deployment until monitoring is clean.

## Rollback

```bash
bin/kamal rollback
```

If DNS was changed and application rollback is not enough, restore the previous DNS target while TTL is still low.

## Restore Drill

Monthly:

- Restore latest PostgreSQL backup into a disposable database.
- Boot Rails against it with production-like env.
- Check admin dashboard, booking inquiries, availability blocks, calendar imports.
- Delete disposable restore target.
