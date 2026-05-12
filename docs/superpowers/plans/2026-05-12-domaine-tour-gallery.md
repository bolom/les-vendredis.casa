# Domaine Tour Gallery Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Redesign the shared gallery into a luxury editorial tour of the full Les Vendredis domaine.

**Architecture:** `_includes/gallery.html` renders the bilingual visible tour and the shared lightbox shell. `assets/js/lightbox.js` stores lightbox image data in visible order with English and French strings. `assets/css/main.css` defines the editorial area panels within the existing design system.

**Tech Stack:** Jekyll, Liquid, static HTML, CSS, vanilla JavaScript.

---

## Task 1: Replace Gallery Markup

**Files:**
- Modify: `_includes/gallery.html`

- [ ] Replace the current grouped grid with five `.domain-area` sections:
  1. Domaine / The Domain: panorama, hillside view, sunset
  2. Cabane / The Cabin: open cabin, A-frame exterior, inside views, window
  3. Jardin tropical / Tropical Garden: anthurium, mangoes, guava, flamboyant, rocks
  4. Vie dehors / Outdoor Living: hammock, breakfast, garden planting, pets
  5. Fabrication / The Making: cladding, facade, hand-built work, family build, structure

- [ ] Use `page.lang == 'fr'` conditionals for section titles, descriptions, captions, and the main section heading.

- [ ] Use `openLightbox(0)` through `openLightbox(21)` in visible order.

## Task 2: Update Lightbox Data

**Files:**
- Modify: `assets/js/lightbox.js`

- [ ] Replace `GALLERY` with 22 objects in the same visible order.
- [ ] Each object must have `title`, `titleFr`, `desc`, and `descFr`.
- [ ] Update `render()` to choose French strings when `document.documentElement.lang` starts with `fr`.

## Task 3: Redesign Gallery CSS

**Files:**
- Modify: `assets/css/main.css`

- [ ] Replace the flat `.gallery-grid`/`.gallery-group` styling with:
  - `.domain-tour`
  - `.domain-area`
  - `.domain-area-copy`
  - `.domain-area-num`
  - `.domain-area-gallery`
  - `.gallery-item.feature`

- [ ] Keep the current `.gallery-item`, `.gallery-caption`, and lightbox behavior compatible.

- [ ] Add responsive rules so each area collapses to one column under `900px`.

## Task 4: Add Gallery To SEO Page

**Files:**
- Modify: `fr/hebergement-atypique-martinique.html`

- [ ] Insert `{% include gallery.html %}` after the first intent-answer section and before the `Ce que c'est vraiment.` FAQ section.

## Task 5: Verify

**Files:**
- Generated: `_site/index.html`, `_site/fr/index.html`, `_site/fr/hebergement-atypique-martinique/index.html`

- [ ] Run `bundle exec jekyll build`.
- [ ] Run `rg -n "Domaine|The Domain|Vie dehors|Outdoor Living|Fabrication|The Making" _site/index.html _site/fr/index.html _site/fr/hebergement-atypique-martinique/index.html`.
- [ ] Run `rg -n "openLightbox\\([0-9]+\\)" _includes/gallery.html`.
- [ ] Confirm indexes run from 0 to 21 in visible order.

## Task 6: Commit And Push

**Files:**
- `_includes/gallery.html`
- `assets/js/lightbox.js`
- `assets/css/main.css`
- `fr/hebergement-atypique-martinique.html`
- `docs/superpowers/plans/2026-05-12-domaine-tour-gallery.md`

- [ ] Commit with `gallery: redesign as domaine tour`.
- [ ] Push `main`.
