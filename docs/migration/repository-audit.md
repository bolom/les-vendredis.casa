# Repository Migration Audit

Date: 2026-09-05

## Current state

- `main` matches `origin/main`; the only local-only repository file at audit time is `AGENTS.md`.
- The root application is the production Jekyll site deployed by GitHub Pages.
- The Rails 8 replacement is tracked under `web/` and already includes availability, iCal imports, booking inquiries and emails, administration, analytics, deployment configuration, and tests.
- The former `lesvendredis-mpp` Hono/SQLite service is referenced by historical design documents but its source is not present in this checkout. No `jquery` or `jQuery` directory exists here.

## Keep through cutover

- Root Jekyll pages, `_posts/`, `fr/`, `_includes/`, `_layouts/`, `assets/`, and `public/images/` remain the production source and rollback path.
- Preserve the route and redirect contract in `url-redirect-inventory.md`.
- Keep `web/` as the migration target and `docs/architecture/0001-rails-monolith.md` as the governing architecture decision.
- Retain privacy-safe analytics and the existing no-PII event allowlist.

## Retire only after validation

- Do not remove Jekyll, GitHub Pages, the legacy API, PM2, or any Tailscale tunnel before Rails staging passes the deployment, data import, email, iCal, SEO, backup, and rollback checks in issue #10.
- Treat the x402 and dynamic-pricing documents in `docs/superpowers/` as historical input, not V1 requirements. Payment remains a V2 decision under issue #11.

## Open work

1. Provision Infomaniak staging and its PostgreSQL, worker, storage, monitoring, HTTPS, and backups.
2. Supply protected 1Password/Kamal secrets and validate a staging deploy plus rollback.
3. Verify the Resend domain DNS and perform the controlled staging smoke send (issue #17).
4. Import real blocks/reservations, run Airbnb and Booking iCal sync, and exercise the complete FR/EN booking and admin flows.
5. Reconcile the missing legacy `lesvendredis-mpp` checkout separately before retiring its endpoints or data.

## Verification note

Automated checks could not run on this machine during the audit because only system Ruby 2.6 is active. Both applications require Ruby 3.3.0; the root lockfile requires Bundler 2.3.25 and `web/Gemfile.lock` requires Bundler 2.5.3. Install/select Ruby 3.3.0 before treating this checkout as release-ready.
