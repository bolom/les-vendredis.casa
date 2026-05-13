# Mobile story-first booking design

**Date:** 2026-05-13
**Scope:** Homepage mobile UX, booking hierarchy, EN + FR copy behavior

---

## Context

The homepage should primarily communicate Les Vendredis as a family place with a lived-in story, not as a standard rental product. Booking still matters, but it should stay available as a quiet utility instead of taking over the page.

The current mobile homepage adapts the desktop layout: hero text, image, credentials, then story sections. It works responsively, but the mobile hierarchy still feels like a rental landing page. The redesign should make the mobile experience feel more like entering the domain while keeping one clear path to book.

---

## Design direction

Use a story-first mobile homepage with one primary action:

- Airbnb is the only booking CTA.
- WhatsApp is contact support, not a competing CTA.
- The homepage should lead with atmosphere, family, and place.
- Booking should be persistent and easy to find, but visually calm.

---

## Mobile first viewport

The first viewport should behave like a postcard:

- Real garden/cabin image is the visual anchor.
- Headline and lead stay readable below the image rather than over it.
- Copy emphasizes the family domain and lived-in quality.
- A compact sensory strip can summarize the feeling of the place: garden, preau, hammocks, quiet hills.
- The first screen should not push a large booking block.

Desktop can keep its current editorial split if it remains coherent.

---

## Sticky mobile booking bar

Add a mobile-only sticky bottom booking bar.

Behavior:

- Appears on mobile after the visitor has begun scrolling, or is present from the start if CSS-only implementation is simpler.
- Fixed to the bottom with safe-area padding for modern phones.
- Does not cover page content; body/main spacing must account for it.
- Hidden on desktop.

Hierarchy:

- One primary button: `Book` / `Reserver`
- Link target: Airbnb listing
- Secondary text may identify the action: `Stay at Les Vendredis` / `Sejourner aux Vendredis`
- WhatsApp should not appear as an equal button in the sticky bar.

Example EN:

```text
Stay at Les Vendredis    Book
```

Example FR:

```text
Sejourner aux Vendredis    Reserver
```

---

## WhatsApp treatment

WhatsApp remains available, but as contact:

- In booking sections, show it as a quieter text link such as `Question? WhatsApp` / `Une question ? WhatsApp`.
- Do not style it as a second primary CTA next to Airbnb.
- The visual hierarchy should make it clear that Airbnb is the action and WhatsApp is conversation.

---

## Homepage order

Keep the homepage story-first. Do not move the full gallery above the story just to create a sales funnel.

Recommended mobile reading order:

1. Postcard hero
2. Sensory strip / compact place cues
3. Short family-place note
4. Story sections: journal and hosts remain important
5. Visual and practical details
6. Final booking section with Airbnb primary and WhatsApp secondary

Existing include order can remain if the visual hierarchy is improved with CSS and small component changes.

---

## Implementation notes

Likely files:

- `_includes/hero.html`
- `_includes/hero-fr.html`
- `_includes/booking.html`
- `_includes/booking-fr.html`
- `_layouts/default.html` if a global sticky bar include is cleaner
- `assets/css/main.css`
- Optional small JavaScript only if scroll-triggered reveal is needed

Prefer CSS-only if possible. Keep the change small and avoid new dependencies.

---

## Success criteria

- On mobile, the homepage feels like a story about the place and family before it feels like a rental page.
- Airbnb is the only visually primary booking action.
- WhatsApp is clearly secondary contact.
- A visitor ready to book can always find the Airbnb action without searching.
- The sticky bar does not obscure footer, booking content, or interactive elements.
- Desktop is not degraded.
