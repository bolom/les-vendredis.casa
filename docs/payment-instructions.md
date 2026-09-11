# Payment instructions (Issue #92)

The booking confirmation journey (public confirmation page + `guest_acceptance`
email) displays clear payment instructions: amount due, method, due date,
instructions, and bank details — in FR and EN, consistent between page and email.

## Configuration

Both helpers read from `AppConfig.fetch`, i.e. Rails credentials first, then env
vars, then the baked default:

| Setting                            | Credential path      | Env var                    | Default |
|------------------------------------|----------------------|----------------------------|---------|
| Bank details (IBAN / holder)       | `:payment, :bank_details` | `PAYMENT_BANK_DETAILS`   | `""`    |
| Payment deadline (in days)         | `:payment, :deadline_days` | `PAYMENT_DEADLINE_DAYS` | `7`     |

There is no new DB column or migration — `lib/app_config.rb` covers it.

### Setting a value

```sh
EDITOR=vim rails credentials:edit
# payment:
#   bank_details: "IBAN FR76 ... — Les Vendredis"
#   deadline_days: 7
```

Or via env var on the host: `PAYMENT_BANK_DETAILS="IBAN FR76 ..."`.

`payment_bank_details_helper` (app/helpers/payment_instructions_helper.rb, used
by both the confirmation page and the mailer) returns `nil` when the setting is
empty; the banking section is then simply not rendered, so nothing is shown
unconfigured.

## Where it renders

- Public page: `app/views/booking_inquiries/show.html.erb`, `inquiry-payment`
  section — replaces the old "details emailed to you" wording with the amount,
  deadline and bank details inline.
- Email: `app/views/booking_inquiry_mailer/guest_acceptance.html.erb` /
  `.text.erb`, new "PAIEMENT / PAYMENT" section with the same data.
- Helper exposed as `app/helpers/payment_instructions_helper.rb`, included in
  `ApplicationController` and `ApplicationMailer` so both surfaces share one
  implementation.
