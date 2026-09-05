# Repository Guidelines

## Project Structure & Module Organization

The repository contains two Ruby applications. The production Jekyll site lives at the root: page content is in root and `fr/` HTML files, journal posts are in `_posts/` and `fr/journal/`, reusable Liquid fragments are in `_includes/`, and layouts are in `_layouts/`. Browser code is under `assets/`; optimized media belongs in `public/images/`. Root checks live in `test/`.

The Rails 8 replacement is isolated in `web/` until migration cutover. Application code is in `web/app/`, configuration in `web/config/`, migrations in `web/db/`, and tests in `web/test/`. Architecture decisions belong in `docs/`. Do not edit generated `_site/` output.

## Build, Test, and Development Commands

For Jekyll (repository root):

- `bundle install` installs Ruby dependencies.
- `bundle exec jekyll serve` starts the local preview server.
- `bundle exec jekyll build` generates `_site/` with strict Liquid checking.
- `bundle exec rake test` builds the site, then validates internal links and image references.
- `ruby test/analytics_static_test.rb` runs the focused analytics allowlist test.

For Rails, run from `web/`:

- `bin/setup --skip-server` prepares dependencies and the database.
- `bin/rails test` runs the Minitest suite.
- `bin/ci` runs the full project checks; `bin/rubocop`, `bin/brakeman --no-pager`, and `bin/bundler-audit` run style and security checks individually.

## Coding Style & Naming Conventions

Use two-space indentation for Ruby, YAML, HTML, CSS, and JavaScript. Follow existing Liquid and front-matter patterns, use lowercase kebab-case for public page and image filenames, and descriptive snake_case for Ruby files and methods. Rails code must pass the repository's `rubocop-rails-omakase` configuration. Keep French and English routes aligned when changing translated content.

## Testing Guidelines

Tests use Minitest and follow `*_test.rb` naming. Add Rails tests beside the relevant layer (`web/test/models`, `controllers`, `services`, or `integration`). For static-site changes, run `bundle exec rake test`; verify both locales and ensure every referenced local image exists.

## Commit & Pull Request Guidelines

Recent commits use imperative subjects such as `Add deployment preflight and runbook` and `Fix 1Password vault name`. Keep each commit focused. Pull requests should explain the user-visible impact, list validation performed, link the relevant issue, and include screenshots for layout or styling changes. Call out route, SEO metadata, analytics, database, or deployment changes explicitly.

## Security & Configuration

Never commit credentials or production `.env` files. Rails production secrets are stored in the `lesvendredis.casa` 1Password vault and injected by Kamal. Preserve privacy-safe analytics: do not send names, email addresses, phone numbers, messages, booking references, or stay dates.
