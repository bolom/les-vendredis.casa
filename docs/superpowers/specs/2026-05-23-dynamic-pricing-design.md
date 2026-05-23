# Dynamic Pricing — Les Vendredis

**Date:** 2026-05-23  
**Status:** approved  
**Goal:** Direct booking price is always cheaper than Airbnb, automatically.

## Context

- `lesvendredis-mpp` (Hono/TypeScript, SQLite via better-sqlite3) is the booking API on oldBolo.local
- `competitor-radar-martinique` (Python, SQLite) runs daily at 08:00 AST via cron and snapshots Airbnb prices for known listings
- Les Vendredis listing `1651467419646453001` was registered in the competitor DB on 2026-05-23 — it will now be refreshed daily alongside competitors
- Current Airbnb price observed: **80.13 €/nuit**

## Architecture

No new services. No HTTP calls between projects. `lesvendredis-mpp` reads directly from the competitor-radar SQLite DB (same machine, same user).

```
[cron 08:00 AST — already exists]
  universal_tracker.py --refresh-known
    → snapshots price_night for listing 1651467419646453001
    → writes to ~/code/competitor-radar-martinique/data/universal_tracker.db

[any API call to lesvendredis-mpp]
  → reads latest price_night from competitor DB
  → applies: floor(price_night × 0.90, 65)
  → uses as PRICE for that request
```

## SQL query (competitor DB)

```sql
SELECT ls.price_night
FROM listing_snapshots ls
JOIN listings l ON l.id = ls.listing_id
WHERE l.airbnb_id = '1651467419646453001'
  AND ls.price_night IS NOT NULL
ORDER BY ls.observed_at DESC
LIMIT 1;
```

DB path: `/Users/bolo/code/competitor-radar-martinique/data/universal_tracker.db`

## Pricing formula

```
direct_price = max(floor(airbnb_price * 0.90), 65)
```

- 10% cheaper than Airbnb
- Hard floor: 65 €/nuit (never go below)
- Fallback: if DB unreadable or no snapshot → use 72 € (hardcoded safe default, below current Airbnb)

## Changes per repo

### lesvendredis-mpp (`main.ts` + new `src/pricing.ts`)

1. New `src/pricing.ts` — exports `getLivePrice(): number`
   - Opens competitor DB read-only with better-sqlite3
   - Runs the query above
   - Returns `max(Math.floor(price * 0.90), 65)` or fallback `72`
2. `main.ts` — replace `const PRICE = '80'` with a call to `getLivePrice()` at request time (not module load time, so it picks up the daily refresh without restart)
   - `getQuote()` receives price as a parameter
   - `dynamicPrice()` (x402 middleware) calls `getLivePrice()`
   - `/availability` response uses live price
   - `/rules` response uses live price

### competitor-radar-martinique

No code changes. Listing `1651467419646453001` is already registered and will be refreshed daily by the existing cron.

### les-vendredis.casa

`assets/js/availability.js` already fetches `/availability` which returns a `price` field. Verify it's displayed in `booking.html` — if not, add one line to render it.

## What does NOT change

- x402 payment flow (still EURC on Polygon mainnet)
- Admin endpoints
- Booking rules (min nights, max guests, advance days)
- The competitor radar cron schedule or logic

## Bootstrap (already done)

```bash
cd /Users/bolo/code/competitor-radar-martinique
/usr/local/bin/python3.11 -u scripts/universal_tracker.py 1651467419646453001 --collect-only --max-competitors 0
```

Run ID: `de71713a-222d-4860-b03c-f79faec62dc5`. Price captured: 80.13 €.
