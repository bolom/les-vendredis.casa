# Jekyll Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Migrate the Les Vendredis site from a single `index.html` to Jekyll so journal entries are Markdown files with individual SEO-friendly URLs, a dedicated journal index page, and bilingual FR/EN toggle on entry pages.

**Architecture:** Jekyll 3.9 on GitHub Pages, building from `main`. Entries live in `_posts/` as Markdown files with bilingual frontmatter. Three page types: homepage (N latest posts), journal index (all posts), and individual entry pages at `/journal/:slug/`. Shared header/footer extracted into `_includes/`. CSS extracted into `assets/css/main.css`.

**Tech Stack:** Jekyll 3.9, Liquid templates, GitHub Pages, vanilla JS (language toggle)

---

## File Map

| Action | Path | Responsibility |
|--------|------|----------------|
| Create | `_config.yml` | Site config, permalink pattern, posts_on_homepage |
| Create | `assets/css/main.css` | All site CSS (extracted from current index.html) |
| Create | `_includes/header.html` | Top bar nav markup |
| Create | `_includes/footer.html` | Footer markup |
| Create | `_includes/roman.html` | Integer → Roman numeral Liquid include |
| Create | `_includes/entry-card.html` | Reusable entry card (used on homepage + journal index) |
| Create | `_layouts/default.html` | HTML shell: head, CSS, header, footer |
| Create | `_layouts/post.html` | Individual entry page layout |
| Create | `index.html` | Homepage: N latest posts + gallery + booking (replaces current) |
| Create | `journal/index.html` | All entries index page |
| Create | `_posts/2026-04-12-mangoes.md` | Entry I: mango trees |
| Create | `_posts/2026-05-03-trenches.md` | Entry II: trenches |
| Create | `_posts/2026-05-05-pipe.md` | Entry III: pipe |
| Delete | `journal.html` | Replaced by `journal/index.html` |

---

### Task 1: Jekyll config and CSS extraction

**Files:**
- Create: `_config.yml`
- Create: `assets/css/main.css`

- [ ] **Step 1: Create `_config.yml`**

```yaml
title: Les Vendredis
description: An A-frame cabin and private garden on the southern coast of Martinique.
url: "https://les-vendredis.casa"
baseurl: ""

permalink: /journal/:slug/

posts_on_homepage: 3

plugins:
  - jekyll-feed
```

- [ ] **Step 2: Create `assets/css/main.css`**

Extract the full contents of the `<style>` block from the current `index.html` (lines 12–553) into this file verbatim. Add these additional styles at the end for the language toggle and post layout:

```css
/* ── language toggle ── */
.lang-toggle {
  display: flex;
  gap: 0;
  margin-bottom: 40px;
}
.lang-btn {
  font-size: 10px;
  letter-spacing: .28em;
  text-transform: uppercase;
  font-family: var(--sans);
  font-weight: 500;
  padding: 8px 18px;
  border: 1px solid var(--rule);
  background: transparent;
  color: var(--muted);
  cursor: pointer;
  transition: all .25s;
}
.lang-btn.active {
  background: var(--ink);
  color: var(--cream);
  border-color: var(--ink);
}
.lang-btn:first-child { border-right: none; }

.lang-block { display: none; }
.lang-block.visible { display: block; }

/* ── post page ── */
.post {
  padding: 80px 0 120px;
  max-width: 860px;
}
.post-meta {
  display: flex;
  gap: 20px;
  align-items: baseline;
  margin-bottom: 40px;
  flex-wrap: wrap;
}
.post-num {
  font-family: var(--serif);
  font-style: italic;
  font-size: 32px;
  color: var(--gold);
  font-weight: 400;
  line-height: 1;
}
.post-date {
  font-family: var(--serif);
  font-style: italic;
  font-size: 16px;
  color: var(--ink);
}
.post-tag {
  font-size: 9.5px;
  letter-spacing: .32em;
  text-transform: uppercase;
  color: var(--muted);
  font-weight: 500;
}
.post-image {
  width: 100%;
  aspect-ratio: 16/9;
  overflow: hidden;
  margin-bottom: 48px;
  box-shadow: 0 20px 40px -25px rgba(31,22,17,.3);
}
.post-image img { width: 100%; height: 100%; object-fit: cover; }
.post-title {
  font-family: var(--serif);
  font-weight: 300;
  font-size: clamp(36px, 4vw, 56px);
  line-height: 1.05;
  letter-spacing: -.015em;
  margin-bottom: 32px;
}
.post-title em { font-style: italic; color: var(--accent); }
.post-body p {
  font-family: var(--serif);
  font-size: 20px;
  line-height: 1.65;
  color: var(--ink-soft);
  font-weight: 400;
}
.post-body p + p { margin-top: 16px; }
.back-link {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  font-size: 10.5px;
  letter-spacing: .28em;
  text-transform: uppercase;
  color: var(--muted);
  font-weight: 500;
  margin-bottom: 48px;
  transition: color .25s;
}
.back-link:hover { color: var(--ink); }
```

- [ ] **Step 3: Commit**

```bash
git add _config.yml assets/css/main.css
git commit -m "feat: add Jekyll config and extract CSS"
```

---

### Task 2: Header and footer includes

**Files:**
- Create: `_includes/header.html`
- Create: `_includes/footer.html`

- [ ] **Step 1: Create `_includes/header.html`**

```html
<div class="wrap">
  <header class="top-bar">
    <span class="top-left">Sainte-Luce · Martinique</span>
    <a href="/" class="mark">
      <span class="ornament"></span>Les Vendredis<span class="ornament"></span>
    </a>
    <nav class="top-right">
      <a href="/#journal">Journal</a>
      <a href="/#gallery">Gallery</a>
      <a href="/#stay">Réserver</a>
    </nav>
  </header>
</div>
```

- [ ] **Step 2: Create `_includes/footer.html`**

```html
<div class="wrap">
  <footer class="foot">
    <span class="foot-left">© MMXXVI</span>
    <span class="foot-center">Anaïs &amp; Bolo · Built by hand</span>
    <span class="foot-right">hello@lesvendredis.casa</span>
  </footer>
</div>
```

- [ ] **Step 3: Commit**

```bash
git add _includes/header.html _includes/footer.html
git commit -m "feat: add header and footer includes"
```

---

### Task 3: Roman numeral include

**Files:**
- Create: `_includes/roman.html`

This include expects a variable `include.number` (integer 1–100) and outputs the Roman numeral. Above 100 it outputs the number as-is.

- [ ] **Step 1: Create `_includes/roman.html`**

```liquid
{% comment %}
  Converts an integer to a Roman numeral.
  Usage: {% include roman.html number=forloop.index %}
  Supports 1–100. Above 100, outputs the integer directly.
{% endcomment %}
{% assign n = include.number %}
{% if n == 1 %}I
{% elsif n == 2 %}II
{% elsif n == 3 %}III
{% elsif n == 4 %}IV
{% elsif n == 5 %}V
{% elsif n == 6 %}VI
{% elsif n == 7 %}VII
{% elsif n == 8 %}VIII
{% elsif n == 9 %}IX
{% elsif n == 10 %}X
{% elsif n == 11 %}XI
{% elsif n == 12 %}XII
{% elsif n == 13 %}XIII
{% elsif n == 14 %}XIV
{% elsif n == 15 %}XV
{% elsif n == 16 %}XVI
{% elsif n == 17 %}XVII
{% elsif n == 18 %}XVIII
{% elsif n == 19 %}XIX
{% elsif n == 20 %}XX
{% elsif n == 21 %}XXI
{% elsif n == 22 %}XXII
{% elsif n == 23 %}XXIII
{% elsif n == 24 %}XXIV
{% elsif n == 25 %}XXV
{% elsif n == 26 %}XXVI
{% elsif n == 27 %}XXVII
{% elsif n == 28 %}XXVIII
{% elsif n == 29 %}XXIX
{% elsif n == 30 %}XXX
{% elsif n == 31 %}XXXI
{% elsif n == 32 %}XXXII
{% elsif n == 33 %}XXXIII
{% elsif n == 34 %}XXXIV
{% elsif n == 35 %}XXXV
{% elsif n == 36 %}XXXVI
{% elsif n == 37 %}XXXVII
{% elsif n == 38 %}XXXVIII
{% elsif n == 39 %}XXXIX
{% elsif n == 40 %}XL
{% elsif n == 41 %}XLI
{% elsif n == 42 %}XLII
{% elsif n == 43 %}XLIII
{% elsif n == 44 %}XLIV
{% elsif n == 45 %}XLV
{% elsif n == 46 %}XLVI
{% elsif n == 47 %}XLVII
{% elsif n == 48 %}XLVIII
{% elsif n == 49 %}XLIX
{% elsif n == 50 %}L
{% elsif n == 51 %}LI
{% elsif n == 52 %}LII
{% elsif n == 53 %}LIII
{% elsif n == 54 %}LIV
{% elsif n == 55 %}LV
{% elsif n == 56 %}LVI
{% elsif n == 57 %}LVII
{% elsif n == 58 %}LVIII
{% elsif n == 59 %}LIX
{% elsif n == 60 %}LX
{% elsif n == 61 %}LXI
{% elsif n == 62 %}LXII
{% elsif n == 63 %}LXIII
{% elsif n == 64 %}LXIV
{% elsif n == 65 %}LXV
{% elsif n == 66 %}LXVI
{% elsif n == 67 %}LXVII
{% elsif n == 68 %}LXVIII
{% elsif n == 69 %}LXIX
{% elsif n == 70 %}LXX
{% elsif n == 71 %}LXXI
{% elsif n == 72 %}LXXII
{% elsif n == 73 %}LXXIII
{% elsif n == 74 %}LXXIV
{% elsif n == 75 %}LXXV
{% elsif n == 76 %}LXXVI
{% elsif n == 77 %}LXXVII
{% elsif n == 78 %}LXXVIII
{% elsif n == 79 %}LXXIX
{% elsif n == 80 %}LXXX
{% elsif n == 81 %}LXXXI
{% elsif n == 82 %}LXXXII
{% elsif n == 83 %}LXXXIII
{% elsif n == 84 %}LXXXIV
{% elsif n == 85 %}LXXXV
{% elsif n == 86 %}LXXXVI
{% elsif n == 87 %}LXXXVII
{% elsif n == 88 %}LXXXVIII
{% elsif n == 89 %}LXXXIX
{% elsif n == 90 %}XC
{% elsif n == 91 %}XCI
{% elsif n == 92 %}XCII
{% elsif n == 93 %}XCIII
{% elsif n == 94 %}XCIV
{% elsif n == 95 %}XCV
{% elsif n == 96 %}XCVI
{% elsif n == 97 %}XCVII
{% elsif n == 98 %}XCVIII
{% elsif n == 99 %}XCIX
{% elsif n == 100 %}C
{% else %}{{ n }}{% endif %}
```

- [ ] **Step 2: Commit**

```bash
git add _includes/roman.html
git commit -m "feat: add Roman numeral Liquid include (1-100)"
```

---

### Task 4: Default layout

**Files:**
- Create: `_layouts/default.html`

- [ ] **Step 1: Create `_layouts/default.html`**

```html
<!doctype html>
<html lang="fr">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>{% if page.title %}{{ page.title }} · Les Vendredis{% else %}Les Vendredis · Sainte-Luce, Martinique{% endif %}</title>
  <meta name="description" content="{% if page.description %}{{ page.description }}{% else %}{{ site.description }}{% endif %}" />
  <link rel="preconnect" href="https://fonts.googleapis.com" />
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
  <link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:ital,wght@0,300;0,400;0,500;1,300;1,400&family=Inter+Tight:wght@300;400;500&display=swap" rel="stylesheet" />
  <link rel="stylesheet" href="/assets/css/main.css" />
</head>
<body>
  {% include header.html %}
  {{ content }}
  {% include footer.html %}
</body>
</html>
```

- [ ] **Step 2: Commit**

```bash
git add _layouts/default.html
git commit -m "feat: add default layout"
```

---

### Task 5: Post layout (individual entry page)

**Files:**
- Create: `_layouts/post.html`

The post layout renders a single journal entry with FR/EN language toggle. It uses `page.title_fr`, `page.title_en`, `page.body_fr`, `page.body_en`, `page.image`, `page.image_alt_fr`, `page.tag`, and the Roman numeral calculated from the post's position in `site.posts`.

- [ ] **Step 1: Create `_layouts/post.html`**

```html
---
layout: default
---
{% assign total = site.posts.size %}
{% for p in site.posts %}
  {% if p.url == page.url %}
    {% assign post_number = total | minus: forloop.index0 %}
    {% break %}
  {% endif %}
{% endfor %}

<div class="wrap">
  <article class="post">
    <a href="/journal/" class="back-link">← All entries</a>

    <div class="post-meta">
      <span class="post-num">{% include roman.html number=post_number %}</span>
      <span class="post-date">{{ page.date | date: "%A, %B %-d %Y" }}</span>
      <span class="post-tag">{{ page.tag }}</span>
    </div>

    {% if page.image %}
    <div class="post-image">
      <img src="/public/images/{{ page.image }}" alt="{{ page.image_alt_fr }}" />
    </div>
    {% endif %}

    <div class="lang-toggle">
      <button class="lang-btn active" onclick="setLang('fr', this)">FR</button>
      <button class="lang-btn" onclick="setLang('en', this)">EN</button>
    </div>

    <div class="lang-block visible" id="lang-fr">
      <h1 class="post-title">{{ page.title_fr }}</h1>
      <div class="post-body">{{ page.body_fr | markdownify }}</div>
    </div>

    <div class="lang-block" id="lang-en">
      <h1 class="post-title">{{ page.title_en }}</h1>
      <div class="post-body">{{ page.body_en | markdownify }}</div>
    </div>
  </article>
</div>

<script>
function setLang(lang, btn) {
  document.querySelectorAll('.lang-block').forEach(el => el.classList.remove('visible'));
  document.querySelectorAll('.lang-btn').forEach(el => el.classList.remove('active'));
  document.getElementById('lang-' + lang).classList.add('visible');
  btn.classList.add('active');
}
</script>
```

- [ ] **Step 2: Commit**

```bash
git add _layouts/post.html
git commit -m "feat: add post layout with FR/EN language toggle"
```

---

### Task 6: Entry card include

**Files:**
- Create: `_includes/entry-card.html`

Reusable card used on both the homepage and journal index. Expects `include.post` (a post object) and `include.number` (integer for Roman numeral).

- [ ] **Step 1: Create `_includes/entry-card.html`**

```html
<article class="entry">
  <div class="entry-meta">
    <span class="entry-num">{% include roman.html number=include.number %}</span>
    <span class="entry-date">{{ include.post.date | date: "%A, %B %-d %Y" }}</span>
    <span class="entry-tag">{{ include.post.tag }}</span>
  </div>
  <div class="entry-body">
    <h3><a href="{{ include.post.url }}">{{ include.post.title_fr }}</a></h3>
    <p>{{ include.post.excerpt_fr }}</p>
  </div>
  {% if include.post.image %}
  <div class="entry-img">
    <a href="{{ include.post.url }}">
      <img src="/public/images/{{ include.post.image }}" alt="{{ include.post.image_alt_fr }}" loading="lazy" />
    </a>
  </div>
  {% endif %}
</article>
```

- [ ] **Step 2: Commit**

```bash
git add _includes/entry-card.html
git commit -m "feat: add reusable entry card include"
```

---

### Task 7: Migrate `index.html` to Jekyll template

**Files:**
- Modify: `index.html` (full rewrite as Jekyll template)

Replace the current static `index.html` with a Jekyll template that uses the default layout and loops over recent posts. The gallery, booking, and lightbox sections are copied verbatim from the current file.

- [ ] **Step 1: Rewrite `index.html`**

```html
---
layout: default
---

<!-- HERO -->
<div class="wrap">
  <section class="hero">
    <div class="image-frame">
      <img src="/public/images/IMG_0387.jpg" alt="The A-frame cabin at Les Vendredis" />
      <span class="image-num">No. 01</span>
      <span class="image-cap">The cabin at golden hour</span>
    </div>
    <div>
      <div class="eyebrow">Maison d'hôtes · Sainte-Luce</div>
      <h1>A Friday<br>that <em>lasts.</em></h1>
      <p class="lead">An A-frame cabin and a private garden on the southern coast of Martinique — built by hand by Anaïs, Bolo, Léon and Samsam (our dog).</p>
      <p class="lead">A small house, a wide garden, the sea three minutes down the path.</p>
      <div class="ctas">
        <a class="btn primary" href="https://www.airbnb.fr/rooms/1651467419646453001" target="_blank" rel="noopener">
          Réserver sur Airbnb <span class="arrow">→</span>
        </a>
        <a class="btn" href="https://www.booking.com/hotel/mq/an-atypical-cabin.fr.html" target="_blank" rel="noopener">
          Booking.com <span class="arrow">→</span>
        </a>
      </div>
    </div>
  </section>

  <div class="creds">
    <div class="cred"><span class="k">Location</span><span class="v">Sainte-Luce</span></div>
    <div class="cred"><span class="k">Built</span><span class="v">By hand · 2022—2024</span></div>
    <div class="cred"><span class="k">Sleeps</span><span class="v">Two adults &amp; one child</span></div>
    <div class="cred"><span class="k">To the sea</span><span class="v">Three minutes on foot</span></div>
  </div>
</div>

<!-- JOURNAL -->
<div class="wrap">
  <section class="journal" id="journal">
    <div class="journal-head">
      <h2>The <em>journal.</em></h2>
      <p class="sub">Notes from the build, the garden, and the slow life of Sainte-Luce. Updated by the family.</p>
    </div>

    <div>
      {% assign limit = site.posts_on_homepage | default: 3 %}
      {% assign total = site.posts.size %}
      {% for post in site.posts limit: limit %}
        {% assign post_number = total | minus: forloop.index0 %}
        {% include entry-card.html post=post number=post_number %}
      {% endfor %}
    </div>

    <div class="journal-foot">
      <a href="/journal/" style="color:inherit;border-bottom:1px solid var(--rule);padding-bottom:2px;transition:border-color .25s;">See all entries →</a>
    </div>
  </section>
</div>

<!-- GALLERY -->
<div class="wrap" id="gallery">
  <section class="gallery-section">
    <div class="gallery-head">
      <h2>The <em>place.</em></h2>
      <p class="sub">Views of the cabin, the garden, and the land we built from scratch.</p>
    </div>

    <div class="gallery-grid">
      <div class="gallery-item" onclick="openLightbox(0)">
        <img src="/public/images/IMG_0387.jpg" alt="The A-Frame Exterior" loading="lazy" />
        <div class="gallery-caption"><span>The A-Frame Exterior</span></div>
      </div>
      <div class="gallery-item" onclick="openLightbox(1)">
        <img src="/public/images/IMG_0390.jpg" alt="Verdant Canopy" loading="lazy" />
        <div class="gallery-caption"><span>Verdant Canopy</span></div>
      </div>
      <div class="gallery-item" onclick="openLightbox(2)">
        <img src="/public/images/IMG_0391.jpg" alt="Artisanal Details" loading="lazy" />
        <div class="gallery-caption"><span>Artisanal Details</span></div>
      </div>
      <div class="gallery-item" onclick="openLightbox(3)">
        <img src="/public/images/IMG_0392.jpg" alt="Coastal Proximity" loading="lazy" />
        <div class="gallery-caption"><span>Coastal Proximity</span></div>
      </div>
      <div class="gallery-item" onclick="openLightbox(4)">
        <img src="/public/images/IMG_0396.jpg" alt="Golden Hour" loading="lazy" />
        <div class="gallery-caption"><span>Golden Hour</span></div>
      </div>
      <div class="gallery-item" onclick="openLightbox(5)">
        <img src="/public/images/IMG_0896.jpg" alt="Botanical Sanctuary" loading="lazy" />
        <div class="gallery-caption"><span>Botanical Sanctuary</span></div>
      </div>
      <div class="gallery-item" onclick="openLightbox(6)">
        <img src="/public/images/IMG_0940.jpg" alt="Morning Mist" loading="lazy" />
        <div class="gallery-caption"><span>Morning Mist</span></div>
      </div>
      <div class="gallery-item" onclick="openLightbox(7)">
        <img src="/public/images/IMG_1251.jpg" alt="Natural Light" loading="lazy" />
        <div class="gallery-caption"><span>Natural Light</span></div>
      </div>
      <div class="gallery-item" onclick="openLightbox(8)">
        <img src="/public/images/IMG_1348.jpg" alt="Forest Serenity" loading="lazy" />
        <div class="gallery-caption"><span>Forest Serenity</span></div>
      </div>
      <div class="gallery-item" onclick="openLightbox(9)">
        <img src="/public/images/IMG_1355.jpg" alt="Architectural Detail" loading="lazy" />
        <div class="gallery-caption"><span>Architectural Detail</span></div>
      </div>
      <div class="gallery-item" onclick="openLightbox(10)">
        <img src="/public/images/IMG_3290.jpg" alt="Tropical Flora" loading="lazy" />
        <div class="gallery-caption"><span>Tropical Flora</span></div>
      </div>
      <div class="gallery-item" onclick="openLightbox(11)">
        <img src="/public/images/IMG_3343.jpg" alt="Sunset View" loading="lazy" />
        <div class="gallery-caption"><span>Sunset View</span></div>
      </div>
      <div class="gallery-item" onclick="openLightbox(12)">
        <img src="/public/images/IMG_3936.jpg" alt="Wooden Frame" loading="lazy" />
        <div class="gallery-caption"><span>Wooden Frame</span></div>
      </div>
      <div class="gallery-item" onclick="openLightbox(13)">
        <img src="/public/images/IMG_4621.JPG" alt="Aerial View" loading="lazy" />
        <div class="gallery-caption"><span>Aerial View</span></div>
      </div>
      <div class="gallery-item" onclick="openLightbox(14)">
        <img src="/public/images/IMG_4688.JPG" alt="Mountain Backdrop" loading="lazy" />
        <div class="gallery-caption"><span>Mountain Backdrop</span></div>
      </div>
      <div class="gallery-item" onclick="openLightbox(15)">
        <img src="/public/images/IMG_6303.jpg" alt="Garden Path" loading="lazy" />
        <div class="gallery-caption"><span>Garden Path</span></div>
      </div>
      <div class="gallery-item" onclick="openLightbox(16)">
        <img src="/public/images/IMG_7953.jpg" alt="The Domain" loading="lazy" />
        <div class="gallery-caption"><span>The Domain</span></div>
      </div>
      <div class="gallery-item" onclick="openLightbox(17)">
        <img src="/public/images/AA4940C0-AE7D-4C3A-8304-688BF02A1955.jpg" alt="Garden Path" loading="lazy" />
        <div class="gallery-caption"><span>Garden Path</span></div>
      </div>
    </div>
  </section>
</div>

<!-- BOOKING -->
<section class="booking" id="stay">
  <div class="wrap booking-inner">
    <div>
      <div class="eyebrow">Réservations</div>
      <h2>Come stay in <em>our Friday.</em></h2>
      <p class="booking-sub">Listed on Airbnb and Booking.com. The cabin and the welcome are the same — choose the platform you prefer.</p>
    </div>
    <div class="b-ctas">
      <a class="b-btn" href="https://www.airbnb.fr/rooms/1651467419646453001" target="_blank" rel="noopener">
        <span class="b-label">Airbnb</span><span class="b-meta">Open ↗</span>
      </a>
      <a class="b-btn" href="https://www.booking.com/hotel/mq/an-atypical-cabin.fr.html" target="_blank" rel="noopener">
        <span class="b-label">Booking.com</span><span class="b-meta">Open ↗</span>
      </a>
    </div>
  </div>
</section>

<!-- LIGHTBOX -->
<div class="lightbox" id="lightbox" role="dialog" aria-modal="true">
  <button class="lb-close" onclick="closeLightbox()" aria-label="Close">✕</button>
  <button class="lb-nav lb-prev" onclick="moveLightbox(-1)" aria-label="Previous">‹</button>
  <button class="lb-nav lb-next" onclick="moveLightbox(1)" aria-label="Next">›</button>
  <div class="lb-content">
    <img class="lb-img" id="lb-img" src="" alt="" />
    <div class="lb-caption">
      <h3 id="lb-title"></h3>
      <p id="lb-desc"></p>
      <span class="lb-counter" id="lb-counter"></span>
    </div>
  </div>
</div>

<script>
  const GALLERY = [
    { src: "/public/images/IMG_0387.jpg",  title: "The A-Frame Exterior",  desc: "Sustainable wooden architecture nestled in the lush tropical forest of Martinique." },
    { src: "/public/images/IMG_0390.jpg",  title: "Verdant Canopy",        desc: "The view from the loft, looking out into the heart of the garden." },
    { src: "/public/images/IMG_0391.jpg",  title: "Artisanal Details",     desc: "Hand-crafted local timber used throughout the interior structure." },
    { src: "/public/images/IMG_0392.jpg",  title: "Coastal Proximity",     desc: "Just a short walk from the cabin to the pristine Caribbean shores." },
    { src: "/public/images/IMG_0396.jpg",  title: "Golden Hour",           desc: "Warm light filtering through the palm leaves at dusk." },
    { src: "/public/images/IMG_0896.jpg",  title: "Botanical Sanctuary",   desc: "The private garden surrounding the A-Frame, filled with native flora." },
    { src: "/public/images/IMG_0940.jpg",  title: "Morning Mist",          desc: "The cabin emerging from the mist on a humid tropical morning." },
    { src: "/public/images/IMG_1251.jpg",  title: "Natural Light",         desc: "Sunlight streaming through the architectural lines of the cabin." },
    { src: "/public/images/IMG_1348.jpg",  title: "Forest Serenity",       desc: "Surrounded by the tranquility of untouched tropical nature." },
    { src: "/public/images/IMG_1355.jpg",  title: "Architectural Detail",  desc: "The geometric precision of the A-Frame design against natural elements." },
    { src: "/public/images/IMG_3290.jpg",  title: "Tropical Flora",        desc: "The lush vegetation surrounding and embracing the structure." },
    { src: "/public/images/IMG_3343.jpg",  title: "Sunset View",           desc: "The cabin silhouetted against the Caribbean sunset." },
    { src: "/public/images/IMG_3936.jpg",  title: "Wooden Frame",          desc: "The structural beauty of locally sourced timber." },
    { src: "/public/images/IMG_4621.JPG",  title: "Aerial View",           desc: "A panoramic view from above the cabin and surrounding forest." },
    { src: "/public/images/IMG_4688.JPG",  title: "Mountain Backdrop",     desc: "The A-Frame framed against the dramatic Martinique landscape." },
    { src: "/public/images/IMG_6303.jpg",  title: "Garden Path",           desc: "The winding path leading through the botanical sanctuary." },
    { src: "/public/images/IMG_7953.jpg",  title: "The Domain",            desc: "The full domain — cabin, garden, and sky." },
    { src: "/public/images/AA4940C0-AE7D-4C3A-8304-688BF02A1955.jpg", title: "Garden Path", desc: "Morning light on the garden path." },
  ];

  let current = 0;

  function openLightbox(index) {
    current = index;
    render();
    document.getElementById('lightbox').classList.add('open');
    document.body.style.overflow = 'hidden';
  }

  function closeLightbox() {
    document.getElementById('lightbox').classList.remove('open');
    document.body.style.overflow = '';
  }

  function moveLightbox(dir) {
    current = (current + dir + GALLERY.length) % GALLERY.length;
    render();
  }

  function render() {
    const item = GALLERY[current];
    document.getElementById('lb-img').src = item.src;
    document.getElementById('lb-img').alt = item.title;
    document.getElementById('lb-title').textContent = item.title;
    document.getElementById('lb-desc').textContent = item.desc;
    document.getElementById('lb-counter').textContent = (current + 1) + ' — ' + GALLERY.length;
  }

  document.addEventListener('keydown', e => {
    const lb = document.getElementById('lightbox');
    if (!lb.classList.contains('open')) return;
    if (e.key === 'Escape') closeLightbox();
    if (e.key === 'ArrowRight') moveLightbox(1);
    if (e.key === 'ArrowLeft') moveLightbox(-1);
  });

  document.getElementById('lightbox').addEventListener('click', e => {
    if (e.target === e.currentTarget) closeLightbox();
  });
</script>
```

- [ ] **Step 2: Commit**

```bash
git add index.html
git commit -m "feat: convert homepage to Jekyll template"
```

---

### Task 8: Journal index page

**Files:**
- Create: `journal/index.html`

- [ ] **Step 1: Create `journal/index.html`**

```html
---
layout: default
title: Journal
description: Notes from the build, the garden, and the slow life of Sainte-Luce. Updated by Anaïs, Bolo, Léon and Samsam.
---

<div class="wrap">
  <section class="journal" id="journal">
    <div class="journal-head">
      <h1 style="font-family:var(--serif);font-weight:300;font-size:clamp(48px,5.5vw,80px);line-height:1;letter-spacing:-.015em;">The <em style="font-style:italic;color:var(--accent);">journal.</em></h1>
      <p class="sub">Notes from the build, the garden, and the slow life of Sainte-Luce. Updated by the family.</p>
    </div>

    <div>
      {% assign total = site.posts.size %}
      {% for post in site.posts %}
        {% assign post_number = total | minus: forloop.index0 %}
        {% include entry-card.html post=post number=post_number %}
      {% endfor %}
    </div>
  </section>
</div>
```

- [ ] **Step 2: Commit**

```bash
git add journal/index.html
git commit -m "feat: add journal index page"
```

---

### Task 9: Migrate existing entries to `_posts/`

**Files:**
- Create: `_posts/2026-04-12-mangoes.md`
- Create: `_posts/2026-05-03-trenches.md`
- Create: `_posts/2026-05-05-pipe.md`

- [ ] **Step 1: Create `_posts/2026-04-12-mangoes.md`**

```markdown
---
layout: post
title_fr: "Les manguiers sont lourds encore."
title_en: "The mango trees are heavy again."
tag: The garden
image: IMG_0390.jpg
image_alt_fr: "Jardin à Sainte-Luce, Martinique"
image_alt_en: "Garden in Sainte-Luce, Martinique"
excerpt_fr: "Premières mangues de la saison cette semaine. Le jardin est luxuriant après deux semaines de pluie."
excerpt_en: "First mangoes of the season fell this week. The garden is lush after two weeks of rain."
body_fr: |
  Premières mangues de la saison cette semaine. Le jardin est luxuriant après deux semaines de pluie — le bougainvillier sur le chemin commence à s'ouvrir.

  Nous avons laissé une caisse au portail pour les voisins. Certains sont revenus avec des bananes.
body_en: |
  First mangoes of the season fell this week. The garden is lush after two weeks of rain — the bougainvillea by the path is opening.

  We left a crate at the gate for the neighbours. Some came back with bananas.
---
```

- [ ] **Step 2: Create `_posts/2026-05-03-trenches.md`**

```markdown
---
layout: post
title_fr: "On creuse les tranchées pour l'eau chaude."
title_en: "Digging the trenches for hot water."
tag: Build log
image: IMG_3038.jpg
image_alt_fr: "Creusage des tranchées à Sainte-Luce"
image_alt_en: "Digging trenches in Sainte-Luce"
excerpt_fr: "Ce dimanche nous avons commencé à creuser les tranchées pour amener l'eau chaude dans la cuisine et l'A-frame."
excerpt_en: "This Sunday we started cutting the trenches to bring hot water into the kitchen and the A-frame."
body_fr: |
  Ce dimanche nous avons commencé à creuser les tranchées pour amener l'eau chaude dans la cuisine et l'A-frame.

  Travail lent et chaud — mais chaque ligne dans la terre est une chose de plus faite à la main. Léon a aidé à porter le tuyau.
body_en: |
  This Sunday we started cutting the trenches to bring hot water into the kitchen and the A-frame.

  Slow, hot work — but every line in the dirt is one more thing finished by hand. Léon helped carry the pipe.
---
```

- [ ] **Step 3: Create `_posts/2026-05-05-pipe.md`**

```markdown
---
layout: post
title_fr: "Le tuyau entre, l'eau suit."
title_en: "The pipe goes in, the water follows."
tag: Build log
image: IMG_3594.jpg
image_alt_fr: "Bolo creuse la tranchée pour le tuyau d'eau"
image_alt_en: "Bolo digging the trench for the water pipe"
excerpt_fr: "Deux jours à creuser dans la terre rouge de Martinique. La tranchée court depuis la ligne principale, sous la terrasse, jusqu'à l'A-frame et la cuisine."
excerpt_en: "Two days of digging through the red Martinique earth. The trench runs from the main line, under the terrace, all the way to the A-frame and the kitchen."
body_fr: |
  Deux jours à creuser dans la terre rouge de Martinique. La tranchée court depuis la ligne principale, sous la terrasse, jusqu'à l'A-frame et la cuisine — environ trente mètres de tuyau posés à la main.

  L'eau chaude arrive. Une chose de plus que nous avons construite nous-mêmes, depuis le début.
body_en: |
  Two days of digging through the red Martinique earth. The trench runs from the main line, under the terrace, all the way to the A-frame and the kitchen — about thirty metres of pipe laid by hand.

  Hot water is coming. One more thing we built ourselves, from the ground up.
---
```

- [ ] **Step 4: Commit**

```bash
git add _posts/
git commit -m "feat: add all three journal entries as Jekyll posts"
```

---

### Task 10: Remove old static journal.html and verify

**Files:**
- Delete: `journal.html`

- [ ] **Step 1: Delete `journal.html`**

```bash
git rm journal.html
```

- [ ] **Step 2: Commit**

```bash
git commit -m "chore: remove static journal.html replaced by Jekyll"
```

- [ ] **Step 3: Push and verify on GitHub Pages**

```bash
git push origin main
```

Then open your site and verify:
- `/` — homepage shows 3 latest entries with "See all entries →" link
- `/journal/` — all entries listed
- `/journal/pipe/` — individual entry with FR/EN toggle
- `/journal/trenches/` — individual entry
- `/journal/mangoes/` — individual entry
- FR is default language on all entry pages
- Language toggle switches content without page reload
- Roman numerals: mangoes = I, trenches = II, pipe = III
- Gallery lightbox still works
- Booking links still work
