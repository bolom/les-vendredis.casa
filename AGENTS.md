# Repository Guidelines

## Project Structure & Module Organization

The repository is a single Rails 8 application. Application code is in `app/`, configuration in `config/`, migrations in `db/`, and tests in `test/`. Architecture decisions belong in `docs/`; deployment docs are in `docs/` (`deployment-runbook.md`, `resend-production.md`, `analytics.md`). Optimized media lives in `public/images/`. Kamal deployment config is in `config/deploy.yml`; the production Dockerfile is at the repository root.

## Build, Test, and Development Commands

Run from the repository root:

- `bin/setup --skip-server` prepares dependencies and the database.
- `bin/rails server` starts the local development server.
- `bin/rails test` runs the Minitest suite.
- `bin/ci` runs the full project checks; `bin/rubocop`, `bin/brakeman --no-pager`, and `bin/bundler-audit` run style and security checks individually.
- `bin/deploy-preflight` validates the deployment prerequisites.

## Coding Style & Naming Conventions

Use two-space indentation for Ruby, YAML, HTML, CSS, and JavaScript. Follow Rails conventions, use lowercase kebab-case for public page and image filenames, and descriptive snake_case for Ruby files and methods. Rails code must pass the repository's `rubocop-rails-omakase` configuration. Keep French and English routes aligned when changing translated content.

## Testing Guidelines

Tests use Minitest and follow `*_test.rb` naming. Add Rails tests beside the relevant layer (`test/models`, `controllers`, `services`, or `integration`). Run `bin/rails test` before committing; verify both locales and ensure every referenced local image exists.

## Commit & Pull Request Guidelines

Recent commits use imperative subjects such as `Add deployment preflight and runbook` and `Fix 1Password vault name`. Keep each commit focused. Pull requests should explain the user-visible impact, list validation performed, link the relevant issue, and include screenshots for layout or styling changes. Call out route, SEO metadata, analytics, database, or deployment changes explicitly.

## Security & Configuration

Never commit credentials or production `.env` files. Rails production secrets are stored in the `lesvendredis.casa` 1Password vault and injected by Kamal. Preserve privacy-safe analytics: do not send names, email addresses, phone numbers, messages, booking references, or stay dates.
