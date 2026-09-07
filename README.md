# Les Vendredis

Rails monolith for Les Vendredis, a handmade A-frame cabin and private garden in Sainte-Luce, Martinique.

## Local Development

The active app lives in `web/`.

```bash
cd web
bin/setup --skip-server
bin/rails test
bin/rails server
```

Run `web/bin/deploy-preflight` from the repository root before deployment.
Use two-space indentation, Rails conventions and `web/bin/rubocop`. Tests use
Minitest under `web/test/`; public content and journal records are rendered by Rails.

## Configuration and checkout status

Application secrets belong in encrypted Rails credentials. Only the master key
needs to be retrieved from 1Password; local development uses `web/config/master.key`.
Never commit that key. Development emails are written to `web/tmp/mails`.

Direct enquiries work through `/booking-requests/new` (`?locale=fr` for French).
`/quote` accepts `date`, integer `nights`, `adults` and `children`; legacy `guests`
means adults. Configured checkout uses x402 v2 through a trusted HTTPS facilitator,
persisted quotes and a hold before settlement. `/book` returns 503 when payment
credentials are incomplete or disabled. See [payment operations](docs/architecture/0002-payment-operations.md)
for the client contract and activation requirements. A quote alone never confirms a stay.

Remaining work and acceptance criteria: [correction backlog](docs/migration/2026-09-07-correction-backlog.md).

## Legacy Source

The repository still contains archived legacy source material while the
migration finishes, but the public application and deployment path are now
Rails-first.
