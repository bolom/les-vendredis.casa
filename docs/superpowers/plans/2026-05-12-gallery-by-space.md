# Gallery By Space Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reorganize the homepage gallery into guest-facing space groups while preserving the existing static gallery and lightbox behavior.

**Architecture:** `_includes/gallery.html` owns visible gallery grouping and click indexes. `assets/js/lightbox.js` owns the lightbox data in the same order as the visible grid. `assets/css/main.css` adds lightweight section-heading styles inside the existing gallery section.

**Tech Stack:** Jekyll, Liquid, static HTML, CSS, vanilla JavaScript.

---

## Task 1: Reorder Visible Gallery

**Files:**
- Modify: `_includes/gallery.html`

- [ ] Replace the single `.gallery-grid` contents with four `gallery-group` blocks in this order:
  - Cabin / Cabane: From Inside, Inside Looking Out, The Window, Cabin & Rocks, The A-Frame, Open to the Garden
  - Garden / Jardin: Mango Season, The Guava Tree, The Flamboyant
  - Land / Domaine: The Domain, Sunset on Site, Clearing the Ground, The Land, Day One
  - Making / Construction: The Cladding, Facade Work, Building by Hand, Family Build, The Structure

- [ ] Use language-aware labels:

```liquid
{% if page.lang == 'fr' %}Cabane{% else %}Cabin{% endif %}
```

- [ ] Update every `openLightbox(index)` call so indexes run from 0 to 18 in visible order.

## Task 2: Reorder Lightbox Data

**Files:**
- Modify: `assets/js/lightbox.js`

- [ ] Reorder the `GALLERY` array to exactly match the visible gallery order:
  1. From Inside
  2. Inside Looking Out
  3. The Window
  4. Cabin & Rocks
  5. The A-Frame
  6. Open to the Garden
  7. Mango Season
  8. The Guava Tree
  9. The Flamboyant
  10. The Domain
  11. Sunset on Site
  12. Clearing the Ground
  13. The Land
  14. Day One
  15. The Cladding
  16. Facade Work
  17. Building by Hand
  18. Family Build
  19. The Structure

## Task 3: Add Group Heading Styles

**Files:**
- Modify: `assets/css/main.css`

- [ ] Add styles near the existing gallery CSS:

```css
.gallery-group { display: contents; }
.gallery-group-title {
  grid-column: 1 / -1;
  margin: 40px 0 2px;
  font-family: var(--sans);
  font-size: 12px;
  font-weight: 600;
  letter-spacing: .14em;
  text-transform: uppercase;
  color: var(--muted);
}
.gallery-group:first-child .gallery-group-title { margin-top: 0; }
```

## Task 4: Verify

**Files:**
- Generated output: `_site/index.html`, `_site/fr/index.html`

- [ ] Run:

```bash
bundle exec jekyll build
```

Expected: exit code 0.

- [ ] Run:

```bash
rg -n "Cabane|Jardin|Domaine|Construction|Cabin|Garden|Land|Making" _site/index.html _site/fr/index.html
```

Expected: English page has Cabin/Garden/Land/Making; French page has Cabane/Jardin/Domaine/Construction.

- [ ] Run:

```bash
rg -n "openLightbox\\([0-9]+\\)" _includes/gallery.html
```

Expected: indexes run from 0 through 18 once each.

## Task 5: Commit And Push

**Files:**
- `_includes/gallery.html`
- `assets/js/lightbox.js`
- `assets/css/main.css`
- `docs/superpowers/plans/2026-05-12-gallery-by-space.md`

- [ ] Commit:

```bash
git add _includes/gallery.html assets/js/lightbox.js assets/css/main.css docs/superpowers/plans/2026-05-12-gallery-by-space.md
git commit -m "gallery: organize photos by space"
```

- [ ] Push:

```bash
git push
```
