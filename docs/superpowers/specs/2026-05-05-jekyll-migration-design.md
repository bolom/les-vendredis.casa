# Les Vendredis — Jekyll Migration Design

**Date:** 2026-05-05  
**Status:** Approved

## Goal

Migrate the current single-file `index.html` site to Jekyll so journal entries are written as individual Markdown files. This eliminates the need to duplicate content between `index.html` and `journal.html`, gives each entry its own indexable URL for SEO, and makes adding new entries as simple as writing a `.md` file and pushing to git.

## Hosting

GitHub Pages, native Jekyll 3.9. Builds automatically from the `main` branch on every push. No local Ruby setup required to publish.

## File Structure

```
les-vendredis.casa/
├── _config.yml
├── _layouts/
│   ├── default.html        # header + footer shell
│   └── post.html           # individual entry page
├── _includes/
│   ├── header.html
│   └── footer.html
├── _posts/
│   ├── 2026-04-12-mangoes.md
│   ├── 2026-05-03-trenches.md
│   └── 2026-05-05-pipe.md
├── journal/
│   └── index.html          # all entries page
├── index.html              # homepage
└── public/                 # images, unchanged
```

## Post Frontmatter

Each file in `_posts/` uses this frontmatter schema:

```yaml
---
title_en: "The mango trees are heavy again."
title_fr: "Les manguiers sont lourds encore."
tag: The garden
image: IMG_0390.jpg
image_alt_en: "Garden in Sainte-Luce, Martinique"
image_alt_fr: "Jardin à Sainte-Luce, Martinique"
excerpt_en: "First mangoes of the season fell this week."
excerpt_fr: "Premières mangues de la saison cette semaine."
body_en: |
  Full English body text here.
body_fr: |
  Texte complet en français ici.
---
```

## Pages

### Homepage (`/`)

- Shows the most recent posts, limit configurable via `posts_on_homepage` in `_config.yml` (default: 3)
- Each entry displays: Roman numeral, date, tag, FR title, FR excerpt, image
- "See all entries →" link at the bottom points to `/journal/`
- Gallery, booking, and footer sections unchanged from current design

### Journal page (`/journal/`)

- Shows all posts in reverse chronological order (newest first)
- Each entry shows: Roman numeral, date, tag, FR+EN title, excerpt, image, "Read more →" link
- Same header/footer as homepage

### Individual entry pages (`/journal/:slug/`)

- URL derived from filename: `2026-05-05-pipe.md` → `/journal/pipe/`
- Configured via `_config.yml` permalink: `/journal/:slug/`
- Full entry content: image, date, tag, FR/EN body text
- Language toggle (FR / EN buttons) at top of entry — shows one language at a time, toggled with JavaScript
- Default language: French
- Toggle state resets on each page load (no localStorage persistence)
- Same header/footer as homepage

## Roman Numerals

Auto-calculated in Liquid templates. The most recent post = highest number. Calculated by finding the post's index in `site.posts` (which is reverse-chronological) and computing `site.posts.size - index`.

Numeral conversion handled by a Liquid include `_includes/roman.html` that maps integers 1–100 to Roman numerals. Entries beyond 100 fall back to the Arabic number. The limit is documented in a comment inside the include.

## Design

Unchanged from current site. Same CSS variables, typography (Cormorant Garamond + Inter Tight), color palette (cream/gold/ink/accent), and component styles. CSS is extracted into `assets/css/main.css` and linked from `_layouts/default.html`.

## SEO Benefits

- Each entry has its own URL, title, and meta description → Google can index and rank individual entries
- `post.html` layout sets `<title>` and `<meta name="description">` from frontmatter
- FR and EN content on the same page gives bilingual keyword coverage

## What Is Not Changing

- Visual design and CSS
- Image files in `public/images/`
- Booking links (Airbnb, Booking.com)
- GitHub Pages hosting on `main` branch
- Domain and deployment workflow
