# Analytics checklist

GA4 measurement ID: `G-HD3V7YWDWQ`.

Events:

- `view_availability`
- `select_dates`
- `start_inquiry`
- `submit_inquiry`
- `inquiry_success`
- `click_airbnb`
- `click_booking`
- `click_email`
- `click_whatsapp`

Never send guest name, email, phone, message, inquiry reference, dates, or free-text content to GA4.

Post-deploy validation:

- DebugView shows one `view_availability` event when the calendar loads.
- Calendar navigation emits one `select_dates` event.
- Booking form page emits `start_inquiry`.
- Form submit emits `submit_inquiry`.
- Confirmation page emits `inquiry_success`; mark it as a GA4 conversion.
- Airbnb, Booking, email, and WhatsApp clicks appear as separate outbound events.
- Search Console sitemap is still valid after cutover.

Monthly review:

- Organic visits and top Search Console queries.
- Airbnb/Booking outbound clicks versus direct inquiries.
- Direct inquiry conversion count and conversion rate.
- Pages that start inquiries but do not submit.
