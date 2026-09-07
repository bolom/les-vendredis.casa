# Les Vendredis

Rails monolith for Les Vendredis, a handmade A-frame cabin and private garden
in Sainte-Luce, Martinique. Direct booking, public content and the journal are
all served by this single Rails application.

## Stack

- Ruby 3.3.0
- Rails 8.0
- PostgreSQL
- Hotwire, Turbo and Stimulus
- Propshaft
- Minitest
- Solid Queue, Solid Cache and Solid Cable
- Kamal deployment to Infomaniak

## Local Setup

```bash
bundle install
bin/setup --skip-server
bin/rails test
```

The app uses `America/Martinique` as its business timezone and stores database
timestamps in UTC.

Run `bin/deploy-preflight` before deployment. Direct enquiries work through
`/booking-requests/new` (`?locale=fr` for French). `/quote` accepts `date`,
integer `nights`, `adults` and `children`; legacy `guests` means adults.
Configured checkout uses x402 v2 through a trusted HTTPS facilitator, persisted
quotes and a hold before settlement. `/book` returns 503 when payment
credentials are incomplete or disabled. See
[payment operations](docs/architecture/0002-payment-operations.md) for the
client contract and activation requirements. A quote alone never confirms a stay.

Remaining work and acceptance criteria:
[correction backlog](docs/migration/2026-09-07-correction-backlog.md).

## Admin Access

Public sign-up is disabled. Create the first administrator from a Rails console
or a one-off production task, using credentials stored outside the repository.

```ruby
User.create!(
  email_address: "admin@example.com",
  password: "replace-with-a-generated-password"
)
```

## Environment

Copy `.env.example` only for non-secret local settings. Application secrets live
in `config/credentials.yml.enc`; 1Password supplies the master key to Kamal.

Required production secrets:

- `RAILS_MASTER_KEY`
- `KAMAL_REGISTRY_PASSWORD`

Resend production setup and smoke-test steps are documented in
[`docs/resend-production.md`](docs/resend-production.md).

## Checks

```bash
bin/ci
bin/rubocop
bin/brakeman --no-pager
bin/bundler-audit
```
