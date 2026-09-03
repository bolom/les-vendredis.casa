# Les Vendredis Rails App

Rails V1 for Les Vendredis direct booking. The production public site remains
the root Jekyll app until the migration cutover issue is approved.

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

Copy `.env.example` only for local development. Production/staging secrets live in
the 1Password vault `lesvendredis.casa` and are injected by Kamal.

Required production secrets:

- `DATABASE_URL`
- `RAILS_MASTER_KEY`
- `RESEND_API_KEY`
- `SECRET_KEY_BASE`
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
