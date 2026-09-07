# Rails payment and notification operations

## Contract

Rails implements x402 v2 `exact` EVM payment via a trusted facilitator's `/verify`
and `/settle` endpoints. Sources: [protocol](https://github.com/coinbase/x402/blob/main/specs/x402-specification-v2.md)
and [HTTP transport](https://github.com/coinbase/x402/blob/main/specs/transports-v2/http.md).
No wallet private key is needed by Rails. Mocked facilitator tests are not proof
of real on-chain compatibility or settlement.

1. POST `/quote` with ISO `date`, integer `nights`, `adults`, `children`.
2. Store returned `quoteId`, `expiresAt` and `authorizationNonce`.
3. POST `/book?quote_id=...` to receive a 402 `PAYMENT-REQUIRED` header.
4. A compatible client must use `authorizationNonce` as the signed EIP-3009 nonce
   (SHA-256 of quoteId). This binds a signature to one quote; generic clients that
   always choose a random nonce need adaptation. Set validBefore no later than expiresAt.
5. After the traveller approves payment, retry with `PAYMENT-SIGNATURE` and
   `guest_name`, `email`, `locale`, `contact_consent: "1"`.
6. Only a verified, successful settlement yields `confirmed` and `PAYMENT-RESPONSE`.
   Replay with the same signature returns the existing confirmation without charging again.

## Activation

Store `x402.enabled`, `pay_to`, token contract `asset`, `chain_id`, `decimals`,
`token_name`, `token_version`, `facilitator_url` and optional `facilitator_token`
in Rails encrypted credentials. 1Password holds only the master key. No recipient
or facilitator is guessed. Use a facilitator supporting the chosen EURC contract,
chain and x402 v2; confirm its `/supported` response before activation.

Prices are denominated in euros. This implementation requires EURC, uses the
admin nightly price (credentials fallback), and checks exact base-unit precision.
There is no implicit EUR/USD conversion. Taxes, cancellation/refund policy and
commercial terms must be reviewed before public payment activation.

## Ambiguous settlement and refunds

The tentative availability block is committed before settlement. Timeout,
unexpected settlement response, interrupted process or iCal conflict requires
manual review, visible in the admin dashboard. Holds in settling/review do not
expire automatically: an expired signature does not prove that no transfer occurred.
Never resubmit settlement or release such a hold without reconciliation.

Inspect the facilitator record/on-chain transaction, stored settlement and booking.
Resolve the guest's stay or arrange an authorized refund with recorded transaction
evidence. The admin dashboard records the verified outcome (confirmed, refunded,
or no transfer), evidence, operator and timestamp. It does not execute a refund.
An active settlement cannot be reconciled for five minutes; a known successful
payment cannot be recorded as no transfer. Reconciled refunds release dates and
notify the guest. Keep payment disabled until end-to-end provider validation and
the refund procedure are confirmed. Generic block cancellation cannot release
unresolved/paid payment holds.

## Email delivery

Booking notifications are created in the booking transaction with immutable rendered
payloads. A recurring job recovers pending deliveries every minute. Production uses
Resend HTTP with one deterministic idempotency key per event; local development
writes files and tests use Mail's test transport. SMTP remains for other mailers.

Attempts and a lease are committed before delivery. At most five attempts are made;
ambiguous deliveries older than 23 hours require review rather than automatic resend,
because Resend's idempotency window is 24 hours. The admin dashboard lists failures.
Investigate configuration/payload errors before retrying. See
[Resend idempotency](https://resend.com/docs/dashboard/emails/idempotency-keys).

## Validation status

Automated tests cover successful simulated payment, false verification, replay,
quote binding, expiration, unavailable dates, timeout holds, HTTP challenge format,
stored pricing, durable notifications and retries. Live-chain payment, facilitator
interoperability, refunds and production delivery remain separate launch checks.
