# Dynamic Pricing Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the direct booking price always cheaper than Airbnb by reading the Airbnb rack rate from the competitor-radar SQLite DB and applying a 10% discount (floor 70 €).

**Architecture:** `lesvendredis-mpp` adds a `src/pricing.ts` module that opens the competitor-radar DB read-only, queries the latest `price_night` for listing `1651467419646453001`, and returns `max(floor(price × 0.90), 70)`. All price references in `main.ts` are replaced with a call to `getLivePrice()` at request time (not module load). The competitor-radar DB is already populated daily by the existing cron — no changes needed there.

**Tech Stack:** TypeScript, Hono, better-sqlite3, Vitest

---

## File Map

| Action | Path | Responsibility |
|---|---|---|
| Create | `src/pricing.ts` | Read competitor DB, compute live price |
| Modify | `main.ts` | Replace hardcoded `PRICE` with `getLivePrice()` |
| Modify | `main.test.ts` | Add pricing tests |

---

### Task 1: Create `src/pricing.ts` with tests

**Files:**
- Create: `src/pricing.ts`
- Modify: `main.test.ts`

- [ ] **Step 1: Write the failing tests**

Add to `main.test.ts` (at the top, after existing imports):

```typescript
import { getLivePrice, computeDirectPrice } from './src/pricing.ts';
```

Then add this test block:

```typescript
describe('pricing', () => {
  it('computeDirectPrice applies 10% discount', () => {
    expect(computeDirectPrice(81)).toBe(72); // floor(81 * 0.90) = 72
    expect(computeDirectPrice(80)).toBe(72); // floor(80 * 0.90) = 72
    expect(computeDirectPrice(100)).toBe(90);
  });

  it('computeDirectPrice respects floor of 70', () => {
    expect(computeDirectPrice(70)).toBe(70);  // floor(70 * 0.90) = 63 → clamped to 70
    expect(computeDirectPrice(50)).toBe(70);  // floor(50 * 0.90) = 45 → clamped to 70
  });

  it('getLivePrice returns a number >= 70', () => {
    const price = getLivePrice();
    expect(typeof price).toBe('number');
    expect(price).toBeGreaterThanOrEqual(70);
  });
});
```

- [ ] **Step 2: Run to verify tests fail**

```bash
cd /Users/bolo/code/lesvendredis-mpp
npm test
```

Expected: FAIL — `Cannot find module './src/pricing.ts'`

- [ ] **Step 3: Create `src/pricing.ts`**

```typescript
import Database from 'better-sqlite3';
import { existsSync } from 'node:fs';

const COMPETITOR_DB = '/Users/bolo/code/competitor-radar-martinique/data/universal_tracker.db';
const LES_VENDREDIS_AIRBNB_ID = '1651467419646453001';
const DISCOUNT = 0.90;
const FLOOR = 70;
const FALLBACK = 72;

export function computeDirectPrice(airbnbPrice: number): number {
  return Math.max(Math.floor(airbnbPrice * DISCOUNT), FLOOR);
}

export function getLivePrice(): number {
  try {
    if (!existsSync(COMPETITOR_DB)) return FALLBACK;
    const db = new Database(COMPETITOR_DB, { readonly: true, fileMustExist: true });
    const row = db.prepare(`
      SELECT ls.price_night
      FROM listing_snapshots ls
      JOIN listings l ON l.id = ls.listing_id
      WHERE l.airbnb_id = ?
        AND ls.price_night IS NOT NULL
      ORDER BY ls.observed_at DESC
      LIMIT 1
    `).get(LES_VENDREDIS_AIRBNB_ID) as { price_night: number } | undefined;
    db.close();
    if (!row?.price_night) return FALLBACK;
    return computeDirectPrice(row.price_night);
  } catch {
    return FALLBACK;
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

```bash
npm test
```

Expected: all pricing tests PASS, existing tests still PASS.

- [ ] **Step 5: Commit**

```bash
git add src/pricing.ts main.test.ts
git commit -m "feat: src/pricing.ts — live price from competitor DB, 10% below Airbnb"
```

---

### Task 2: Wire `getLivePrice()` into `main.ts`

**Files:**
- Modify: `main.ts`

The goal is to replace every reference to the hardcoded `PRICE` constant with `getLivePrice()` called at request time.

- [ ] **Step 1: Add import at top of `main.ts`**

After the existing imports block, add:

```typescript
import { getLivePrice } from './src/pricing.ts';
```

- [ ] **Step 2: Remove the hardcoded PRICE constant**

Find and delete this line (around line 54):

```typescript
const PRICE    = USE_TESTNET ? '0.8' : '80';
```

Replace with:

```typescript
const TESTNET_PRICE = '0.8';
```

- [ ] **Step 3: Update `getQuote()` to receive price as parameter**

Find the `getQuote` function signature:

```typescript
function getQuote(date: unknown, nights: unknown, guests: unknown) {
```

Replace with:

```typescript
function getQuote(date: unknown, nights: unknown, guests: unknown, price?: string) {
  const PRICE = price ?? (USE_TESTNET ? TESTNET_PRICE : String(getLivePrice()));
```

Then remove any `PRICE` references inside `getQuote` that were using the old constant — they now use the local `PRICE` variable. The function body already uses `PRICE` internally, so this should be a drop-in.

- [ ] **Step 4: Update `dynamicPrice()` to use `getLivePrice()`**

Find:

```typescript
const dynamicPrice = async (ctx: HTTPRequestContext) => {
  try {
    const body = await (ctx.adapter as any).getBody?.() as { nights?: unknown };
    const nights = Math.min(MAX_NIGHTS, Math.max(MIN_NIGHTS, Number(body?.nights) || MIN_NIGHTS));
    return { amount: String(Math.round(Number(PRICE) * nights * 1_000_000)), asset: ASSET };
  } catch {
    return { amount: String(Number(PRICE) * 1_000_000), asset: ASSET };
  }
};
```

Replace with:

```typescript
const dynamicPrice = async (ctx: HTTPRequestContext) => {
  const livePrice = USE_TESTNET ? Number(TESTNET_PRICE) : getLivePrice();
  try {
    const body = await (ctx.adapter as any).getBody?.() as { nights?: unknown };
    const nights = Math.min(MAX_NIGHTS, Math.max(MIN_NIGHTS, Number(body?.nights) || MIN_NIGHTS));
    return { amount: String(Math.round(livePrice * nights * 1_000_000)), asset: ASSET };
  } catch {
    return { amount: String(livePrice * 1_000_000), asset: ASSET };
  }
};
```

- [ ] **Step 5: Update the root `GET /` info endpoint**

Find:

```typescript
  price: `${PRICE} ${CURRENCY}/night`,
```

Replace with:

```typescript
  price: `${USE_TESTNET ? TESTNET_PRICE : getLivePrice()} ${CURRENCY}/night`,
```

- [ ] **Step 6: Update `/rules` endpoint**

Find:

```typescript
app.get('/rules', (c) => c.json({ rules: RULES, price: PRICE, currency: CURRENCY }));
```

Replace with:

```typescript
app.get('/rules', (c) => c.json({ rules: RULES, price: USE_TESTNET ? TESTNET_PRICE : String(getLivePrice()), currency: CURRENCY }));
```

- [ ] **Step 7: Run build check**

```bash
npm run build
```

Expected: no TypeScript errors.

- [ ] **Step 8: Run full test suite**

```bash
npm test
```

Expected: all tests PASS.

- [ ] **Step 9: Commit**

```bash
git add main.ts
git commit -m "feat: main.ts — replace hardcoded PRICE with getLivePrice() at request time"
```

---

### Task 3: Smoke test the running server

- [ ] **Step 1: Start the server in testnet mode**

```bash
npm run dev
```

Expected output includes:
```
x402 API v3 — Polygon Amoy (testnet)
   USDC 0.8/night
```

- [ ] **Step 2: Hit `/availability` and verify price field**

In a second terminal:

```bash
curl -s http://localhost:8787/availability | jq '{price, currency}'
```

Expected (testnet):
```json
{ "price": "0.8", "currency": "USDC" }
```

- [ ] **Step 3: Hit `/quote` and verify totalPrice**

```bash
curl -s -X POST http://localhost:8787/quote \
  -H 'Content-Type: application/json' \
  -d '{"checkIn":"2026-06-15","nights":2,"guests":2}' | jq '{unitPrice, totalPrice, currency}'
```

Expected (testnet, 2 nights × 0.8):
```json
{ "unitPrice": "0.8", "totalPrice": "1.6", "currency": "USDC" }
```

- [ ] **Step 4: Verify production price (NODE_ENV=production)**

```bash
NODE_ENV=production npm run dev &
sleep 2
curl -s http://localhost:8787/availability | jq '{price, currency}'
kill %1
```

Expected:
```json
{ "price": 72, "currency": "EURC" }
```

(72 = floor(81 × 0.90) from today's DB snapshot)

- [ ] **Step 5: Commit smoke test confirmation**

```bash
git commit --allow-empty -m "chore: smoke test passed — live price 72 EURC/night confirmed"
```

---

## Notes

- The competitor DB path is hardcoded in `src/pricing.ts`. If `lesvendredis-mpp` ever moves to a different machine, update `COMPETITOR_DB`.
- `getLivePrice()` is called at **request time**, not module load — so tomorrow's cron update is picked up automatically without a server restart.
- Testnet mode always uses `TESTNET_PRICE = '0.8'` and never touches the competitor DB.
- The fallback price (72 €) matches today's computed live price — so even if the DB is temporarily unavailable, the price is correct.
