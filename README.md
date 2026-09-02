# Les Vendredis

A Jekyll site for Les Vendredis, a handmade A-frame cabin and private garden in Sainte-Luce, Martinique.

## Local Development

Prerequisites:

- Ruby 3.3
- Bundler

Install dependencies:

```bash
bundle install
```

Run the site locally:

```bash
bundle exec jekyll serve
```

Build the production site:

```bash
bundle exec jekyll build
```

GitHub Pages deploys the generated `_site/` output through `.github/workflows/static.yml`.

## Rails Migration

The Rails replacement app lives in `web/` during the migration so the current
Jekyll site can keep deploying unchanged until the DNS cutover is approved.

```bash
cd web
bin/setup --skip-server
bin/rails test
```

See `docs/architecture/0001-rails-monolith.md` for the accepted architecture
and `docs/migration/url-redirect-inventory.md` for the routes that must be
preserved before launch.
