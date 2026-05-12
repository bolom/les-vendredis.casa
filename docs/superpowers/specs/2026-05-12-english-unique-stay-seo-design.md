# English Unique Stay SEO Design

**Date:** 2026-05-12
**Status:** Approved
**Scope:** Existing English page `/unique-stay-martinique/`, homepage internal link, English FAQ schema

---

## Context

The French SEO page now targets `hebergement insolite en Martinique` clearly and presents Les Vendredis as a full domaine with a cabin, garden, outdoor life, and making story.

The English equivalent already exists at `/unique-stay-martinique/`, but its content is still simpler and more cabin-focused. To make the `hreflang` pair stronger, the English page should carry the same positioning in English without creating a new URL.

---

## Goal

Make `/unique-stay-martinique/` the English landing page for:

- `unique stay in Martinique`
- `unusual accommodation in Martinique`
- `A-frame cabin in Martinique`
- `private tropical garden in Sainte-Luce`

The page should present Les Vendredis as a small private domain, not just a cabin.

---

## Approach

- Keep the existing URL and canonical.
- Keep `unique stay` as the main English phrase.
- Add `unusual accommodation` naturally as a secondary phrase.
- Add the Domaine tour to match the French page.
- Refresh visible FAQ and English FAQ schema to match the page content.
- Strengthen the English homepage FAQ link to the page.

---

## Files to Modify

- `unique-stay-martinique.html`
- `_includes/faq.html`
- `_includes/schema-faq-landing.html`

---

## Success Criteria

- Title, H1, and first screen clearly target `unique stay in Martinique`.
- Page mentions `unusual accommodation`, `A-frame cabin`, `Sainte-Luce`, `private tropical garden`, `pets welcome`, and key exclusions.
- Domaine tour appears on the English page.
- English FAQ schema matches the refreshed English FAQ.
- `bundle exec jekyll build` succeeds.
