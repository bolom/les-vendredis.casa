# Domaine Tour Gallery Design

**Date:** 2026-05-12
**Status:** Approved
**Scope:** Homepage gallery, French SEO page gallery, shared lightbox

---

## Context

The gallery currently behaves like a grouped photo grid. It is clearer than the original mixed grid, but it still treats every image with equal weight. That does not match the desired positioning: Les Vendredis should feel like a small private domaine with several spaces, not only an A-frame cabin.

The current design system is editorial and restrained: cream background, ink text, gold accents, serif emphasis, thin rules, spacious sections, and image-led storytelling.

---

## Goal

Redesign the gallery into a more luxurious "Domaine tour" that helps visitors understand each area of Les Vendredis:

- the wider domaine and hillside setting
- the A-frame cabin
- the tropical garden
- outdoor living
- the making of the place

The gallery should feel curated rather than catalog-like.

---

## Design

Use one shared include for English and French.

Each area is an editorial panel:

- small area number: `01`, `02`, etc.
- area title
- short area description
- one large lead image
- two to four supporting images

The order is:

1. Domaine / The Domain
2. Cabane / The Cabin
3. Jardin tropical / Tropical Garden
4. Vie dehors / Outdoor Living
5. La fabrication / The Making

The homepage and the French SEO page both use this gallery. The SEO page should place the gallery after the first intent-answer section and before the detailed FAQ.

---

## Behavior

- Keep the existing lightbox interaction.
- Reorder and expand the lightbox data to match the visible tour order.
- Make lightbox titles and descriptions language-aware from `document.documentElement.lang`.
- Do not add tabs, filters, carousels, or dependencies.
- Keep hover behavior restrained and premium.

---

## Files to Modify

- `_includes/gallery.html`
- `assets/js/lightbox.js`
- `assets/css/main.css`
- `fr/hebergement-atypique-martinique.html`

---

## Success Criteria

- Gallery feels like a guided tour of the domaine, not a flat grid.
- English pages show English area titles, captions, and lightbox text.
- French pages show French area titles, captions, and lightbox text.
- The French SEO page includes the gallery.
- Lightbox opens the clicked image and moves in visible order.
- `bundle exec jekyll build` succeeds.
