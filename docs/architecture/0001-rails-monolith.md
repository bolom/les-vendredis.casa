# ADR 0001: Rails monolith for the public site and direct booking

- **Status:** Accepted for the Rails V1 implementation
- **Date:** 2026-09-02
- **Decision owners:** Les Vendredis product owner; implementation owner to be assigned

## Context

The current public site is a Jekyll 4.3 site deployed by GitHub Pages. It has a bilingual public surface, image assets, journal content, JSON-LD, `robots.txt`, `llms.txt`, and three generated sitemap entry points. Its informational calendar is a browser-side fetch to a separate `GET https://api.lesvendredis.casa/availability` service.

The legacy booking service is documented in this repository but is not part of it: it was TypeScript/Hono, SQLite-backed, and exposed availability, quote/rules, admin and x402 payment behaviour. Its runtime was coupled to a personal machine and local data. That split makes a direct-booking path dependent on a separate process and network endpoint.

The Rails V1 goal is to make one deployable application own public pages, availability, booking enquiries, administration and outbound email. It must preserve public URLs and search signals while avoiding a payment launch during the migration.

## Decision

Build a server-rendered **Rails 8** application on Ruby 3.3+ and PostgreSQL. Use conventional Rails components:

| Concern | Decision |
| --- | --- |
| UI | ERB + Turbo/Stimulus; preserve the existing CSS/design language; no SPA |
| Database | PostgreSQL, with `America/Martinique` as the business timezone |
| Tests | Minitest for models, jobs, mailers, requests and critical system journeys |
| Admin auth | Rails authentication generator or equivalent session-based single-admin auth; no public sign-up |
| Async work | Active Job + Solid Queue for iCal imports and email delivery |
| Files | Active Storage for newly uploaded assets; retain legacy public image paths during cutover |
| Email | Resend transactional API; sender defaults to `hello@lesvendredis.casa` |
| Hosting | Infomaniak server managed by Kamal; PostgreSQL backups enabled; object storage selected only when Active Storage requires it |
| Secrets | 1Password is the source of truth; Kamal injects runtime secrets and no secret values are committed |
| Monitoring | Kamal/Rails health checks plus application error tracking and uptime monitoring, configured during deployment issue #10 |

No deployment or credential configuration is made by this ADR.

## Domain model for V1

`Accommodation` is intentionally not needed in V1 because there is one bookable property. Use the following bounded model:

| Record | Purpose | Key fields |
| --- | --- | --- |
| `AvailabilityBlock` | Manual closure or confirmed direct stay | `starts_on`, `ends_on`, `kind`, `note`, `source` |
| `CalendarImport` | A configured external calendar source, never its URL in Git | `provider`, `active`, `last_synced_at`, `last_error_at` |
| `CalendarEvent` | Normalized event imported from iCal | `calendar_import_id`, `external_uid`, `starts_on`, `ends_on`, `status`, `fingerprint` |
| `BookingInquiry` | A traveller request; non-blocking until confirmed | dates, guest counts, contact details, locale, status, consent timestamp |
| `SiteSetting` | Admin-editable display price and selected copy/settings | validated key/value records; secrets excluded |

Date ranges are half-open: `starts_on` is check-in and `ends_on` is check-out. A booking ending on a date does not block another beginning on that same date. The availability service is derived from `AvailabilityBlock` and active imported `CalendarEvent` records; it is never maintained as a hand-written day table.

## Availability and calendar contract

The public V1 contract replaces the external endpoint while preserving its useful response shape:

```http
GET /availability?from=YYYY-MM-DD&to=YYYY-MM-DD
```

```json
{
  "days": [{"date":"2026-10-01","available":true}],
  "generated_at":"2026-09-02T12:00:00Z"
}
```

Rules:

- `from` and `to` are required ISO dates; maximum range is 93 days in V1.
- A day is unavailable when it overlaps a manual block, a confirmed direct booking, or an active imported external event.
- Pending enquiries are **not** blocks. Only an administrator confirmation creates a block.
- The response has no guest, price, source-calendar or personally identifying data.
- A Rails controller and the server-rendered calendar must read the same availability service object.

## External calendar handling

Airbnb and Booking iCal feed URLs are credentials. They are stored in 1Password and injected by Kamal, not in the database, source tree, logs, issue, PR or test fixtures. Each import records only provider metadata and a non-secret identifier.

The import job runs at a conservative periodic interval, validates iCalendar payloads, deduplicates by provider UID plus range fingerprint, and keeps the last known good events if a remote fetch fails. It must never create a direct booking automatically. Manual refresh may be available to the administrator after rate-limit protection.

## Explicit V1 product decisions

1. Direct booking begins as a **request**: submission sends acknowledgement/owner emails and remains non-blocking until Bolo confirms it.
2. The site supports French and English public routes. Locale follows the current URL, not browser-only inference.
3. The public facts currently stated on the site are the provisional V1 defaults: 2 adults, 1 child, pets welcome; one night only depending on dates; two nights preferred. Final validation rules must be confirmed in issue #13 before enforcement.
4. Stay rules and display price are manually editable in admin. No minimum stay is hard-coded in V1. The legacy rule “10% below Airbnb, floor EUR70, fallback EUR72” is **not migrated** to V1. It depended on a local competitor database and is retired pending an explicit future pricing decision.
5. Legacy x402/EURC payment and associated quote/payment endpoints are **out of scope** for V1. Issue #11 is the only place to decide a payment product later.

## SEO and compatibility rules

- Preserve canonical host `https://lesvendredis.casa`.
- Preserve every public route in `docs/migration/url-redirect-inventory.md`; serve it directly where practical, otherwise use a permanent redirect.
- Preserve titles, descriptions, canonical URLs, `hreflang` relationships, JSON-LD, `robots.txt`, `llms.txt`, `.well-known/agent.json`, sitemap index and image paths in the first cutover.
- Keep `/come-stay/` and `/fr/venir-dormir/` noindex unless the product owner explicitly changes that decision.
- Generate sitemaps from Rails and submit only after production verification; do not remove the old GitHub Pages deployment until redirect and crawl checks pass.

## Security and data retention

- Public forms use CSRF protection, server-side validation, rate limiting and a honeypot or equivalent anti-spam control.
- Admin session controls require secure cookies, password management outside source control and no public registration.
- Booking enquiries hold only data needed to respond. The retention/deletion period and privacy copy are open product decisions that must be approved before the form goes live.
- Logs must redact calendar feed URLs, mail credentials and traveller contact data.

## Consequences

This removes the personal-machine runtime dependency and makes the direct-booking path observable and testable. It introduces a managed database, job runner, email provider and hosting cost. The implementation sequence is #6 foundations, #7 public migration, #13 availability/iCal, #14 enquiry/email, #9 admin, #15 analytics, then #10 production cutover. Payment remains #11 after V1 proves useful.

## Open decisions that block only their named work

- FR/EN email wording: #14.
- Guest and pet constraints to enforce rather than merely display: #13.
- Traveller data retention period and privacy wording: #14 before launch.
- Object-storage provider if media uploads exceed local disk needs: #10.
