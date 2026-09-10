# Deployment runbook

## Preconditions

- Infomaniak app host is provisioned.
- PostgreSQL is provisioned and backup policy is active.
- `lesvendredis.casa` DNS is ready.
- Kamal can read secrets from the 1Password vault `lesvendredis.casa` without interactive prompts.
- `KAMAL_1PASSWORD_ACCOUNT` is exported locally with the 1Password account identifier.
- Resend domain is verified; see `docs/resend-production.md`.

Secrets architecture, rotation checklist and the exact mirror set used by
the deploy CI are documented in [`docs/secrets.md`](secrets.md).

Required Kamal secrets (local deploys, via 1Password):

- `RAILS_MASTER_KEY`
- `POSTGRES_PASSWORD`
- `KAMAL_REGISTRY_PASSWORD`

Application runtime secrets (`SECRET_KEY_BASE`, `DATABASE_URL`, `RESEND_API_KEY`,
calendar URLs, x402 settings) live in `config/credentials.yml.enc`, unlocked by
`RAILS_MASTER_KEY`.

The private outbound calendar token and the Airbnb/Booking subscription steps
are documented in [`docs/ical-export.md`](ical-export.md).

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

## Pre-production preview (before the public cutover)

There is a single production deployment. Until the public cutover, the Caddy
reverse proxy on the VPS serves the app through the transition Docker label
in `config/deploy.yml`, so the real site stays on GitHub Pages untouched.
At cutover, set the `caddy` label to `lesvendredis.casa`, lower the DNS TTL,
and redeploy.

1Password prerequisites (vault `lesvendredis.casa`, item `production`):

- `RAILS_MASTER_KEY` = the value of `config/master.key`
- `POSTGRES_PASSWORD` = the database password (also baked into the
  `DATABASE_URL` that Kamal builds from it)

The Postgres accessory lives in the `les-vendredis-db` container on the same
VPS (volume `les_vendredis_db`, bound to the Docker bridge gateway so it is
not exposed to the internet).

Deploy:

```bash
export KAMAL_1PASSWORD_ACCOUNT=<account id>
bin/kamal setup      # first deploy: docker, proxy, Postgres accessory, app
bin/kamal deploy
```

Verify:

```bash
curl -fsS https://lesvendredis.casa/up
bin/kamal app exec "bin/rails production:check"
bin/kamal logs
```

Rollback:

```bash
bin/kamal rollback <version>
```

## Production Cutover

Before cutover:

- Lower DNS TTL.
- Freeze changes on the old system.
- Export any manual booking/blocking state.
- Run final iCal sync after deploy.
- Configure `calendars.export_token`, subscribe Airbnb and Booking.com to the
  private export URL, and verify the feed as described in `docs/ical-export.md`.

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

```bash
sudo /usr/local/sbin/les-vendredis-postgres-restore-drill
```

The command restores the latest custom-format dump into a disposable PostgreSQL
16 container, verifies that public tables exist, and always removes the
container. It never connects the application to the restored database.

## Backups and monitoring

The VPS runs `les-vendredis-backup.timer` daily at 02:15 UTC (with up to ten
minutes of randomized delay). Dumps are mode `0600` under
`/var/backups/les-vendredis`; the default retention is 14 days. The source
scripts and systemd units live under `ops/` and are installed with:

```bash
sudo install -m 0755 ops/postgres-backup /usr/local/sbin/les-vendredis-postgres-backup
sudo install -m 0755 ops/postgres-restore-drill /usr/local/sbin/les-vendredis-postgres-restore-drill
sudo install -m 0644 ops/systemd/les-vendredis-backup.service /etc/systemd/system/
sudo install -m 0644 ops/systemd/les-vendredis-backup.timer /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now les-vendredis-backup.timer
```

`Production Monitor` runs from GitHub Actions twice per hour. A failed workflow
opens (or updates) a GitHub issue labeled `production-alert`. It checks the production `/up` endpoint and, over SSH, verifies
the web container, Solid Queue worker, failed jobs, iCal freshness, failed
booking emails, administrator presence, and a non-empty backup newer than 26
hours. Install its server-side check with:

```bash
sudo install -m 0755 ops/production-health-check /usr/local/sbin/les-vendredis-production-health-check
```

Verify the alert path after changing the monitor by dispatching it with
`verify_alert=true`. The health checks run first, then the controlled failure
must produce a failed workflow and an observable `production-alert` issue.
Close the alert issue after recording that the drill—not production—caused it.
