# Gallery by Space Design

**Date:** 2026-05-12
**Status:** Approved
**Scope:** Homepage gallery organization and lightbox order

---

## Context

The current gallery is one continuous mixed grid. It combines garden photos, cabin photos, wider land photos, and construction photos in a single flow. That makes the place harder to understand as a guest because the booking-relevant spaces are mixed with the build story.

The gallery include is shared by the English and French homepages, while the lightbox order is maintained separately in `assets/js/lightbox.js`.

---

## Goal

Organize the gallery by guest-facing spaces first, then place the construction story last.

The visitor should quickly understand:

- what the cabin looks like
- what the private garden feels like
- how the land sits in Sainte-Luce
- how the place was made

---

## Structure

Use four groups:

1. Cabin / Cabane
2. Garden / Jardin
3. Land / Domaine
4. Making / Construction

The French homepage must show French group labels. The English homepage must show English group labels.

---

## Behavior

- Keep the existing static grid style.
- Add small group headings between photo groups.
- Keep the existing lightbox behavior.
- Reorder `GALLERY` in `assets/js/lightbox.js` to match the visible order.
- Update each `openLightbox(index)` call to match the new order.
- Do not add tabs, filters, new dependencies, or extra interaction.

---

## Files to Modify

- `_includes/gallery.html`
- `assets/js/lightbox.js`
- `assets/css/main.css` only if headings need light styling

---

## Success Criteria

- Gallery is grouped by Cabin, Garden, Land, Making.
- French homepage shows Cabane, Jardin, Domaine, Construction.
- English homepage shows Cabin, Garden, Land, Making.
- Lightbox opens the clicked image and next/previous follows visible order.
- `bundle exec jekyll build` succeeds.
