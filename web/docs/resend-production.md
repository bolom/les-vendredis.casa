# Resend production checklist

Use `hello@lesvendredis.casa` as sender and reply-to. Keep `RESEND_API_KEY` only in the 1Password vault `lesvendredi.casa` and Kamal secrets.

## Domain

Prefer adding `send.lesvendredis.casa` in Resend to avoid conflicts with the root email domain. If the root domain is required, use Resend's exact DNS records.

Required DNS, copied from Resend after domain creation:

- SPF/TXT record
- DKIM CNAME records
- bounce/MX record when custom return path is enabled
- DMARC TXT record for the sending domain

Cloudflare proxy must be disabled for every Resend DNS record.

## Rails/Kamal

Required environment:

- `MAIL_FROM=Les Vendredis <hello@lesvendredis.casa>`
- `MAIL_REPLY_TO=hello@lesvendredis.casa`
- `BOOKING_OWNER_EMAIL=hello@lesvendredis.casa`
- `RESEND_API_KEY` as a Kamal secret

Store `RESEND_API_KEY` in 1Password:

- Vault: `lesvendredi.casa`
- Item: `production` for production
- Item: `staging` for staging
- Field name: `RESEND_API_KEY`

Staging smoke test, after deploy:

```bash
bin/rails resend:smoke RAILS_ENV=staging RESEND_SMOKE_TO=delivered@resend.dev
```

Production smoke test needs explicit opt-in:

```bash
ALLOW_PRODUCTION_EMAIL_SMOKE=1 bin/rails resend:smoke RAILS_ENV=production RESEND_SMOKE_TO=hello@lesvendredis.casa
```
