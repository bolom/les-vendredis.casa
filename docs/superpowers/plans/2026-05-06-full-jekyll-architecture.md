# Full Jekyll Architecture Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Convert the site to a single Jekyll codebase — one header, one footer, one CSS file, proper layouts and includes — so every page looks and behaves consistently.

**Architecture:** `default.html` is the single HTML shell (head, fonts, CSS, header include, footer include, per-page scripts). A `page.html` layout wraps simple pages; `article.html` handles journal posts. All homepage sections become includes. `main.css` absorbs all inline styles from `index.html`. The static `index.html` and `fr/index.html` become Jekyll pages using frontmatter.

**Tech Stack:** Jekyll 4, Liquid templates, `main.css` (no preprocessor), vanilla JS (`lightbox.js`, `lang-toggle.js`)

---

## File Map

**Modified:**
- `_layouts/default.html` — add per-page scripts loop, remove duplicate font links (already added)
- `_includes/header.html` — redesign to match `.top-bar` style from `index.html`
- `_includes/footer.html` — replace minimal footer with 3-column `.foot` design
- `assets/css/main.css` — absorb all inline styles from `index.html`, remove dead rules, deduplicate
- `index.html` — convert to Jekyll frontmatter + includes, remove inline `<style>` and `<script>`
- `fr/index.html` — same conversion as `index.html` (French content)
- `journal/index.html` — remove duplicate font link, fix section class
- `fr/journal/index.html` — same cleanup

**Created:**
- `_layouts/page.html` — minimal layout for homepage and simple pages
- `_includes/hero.html` — hero section + credentials strip
- `_includes/hero-fr.html` — French version of hero
- `_includes/journal-preview.html` — 3 latest EN posts
- `_includes/journal-preview-fr.html` — 3 latest FR posts
- `_includes/gallery.html` — photo grid + lightbox HTML
- `_includes/booking.html` — dark booking strip (EN)
- `_includes/booking-fr.html` — dark booking strip (FR)
- `_includes/faq.html` — FAQ section
- `_includes/faq-fr.html` — FAQ section (FR)
- `assets/js/lightbox.js` — extracted lightbox JS from `index.html`

**Deleted:**
- `_layouts/post.html` — duplicate of `article.html`
- `journal.html` — redirect shim, no longer needed
- `articles/index.html` — stale redirect

---

## Task 1: Create `page.html` layout and extract lightbox JS

**Files:**
- Create: `_layouts/page.html`
- Create: `assets/js/lightbox.js`
- Delete: `_layouts/post.html`

- [ ] **Step 1: Create `_layouts/page.html`**

```html
---
layout: default
---
{{ content }}
```

- [ ] **Step 2: Create `assets/js/lightbox.js`**

```js
const GALLERY = [
  { src: "public/images/IMG_0387.jpg",  title: "The A-Frame Exterior",  desc: "Sustainable wooden architecture nestled in the lush tropical forest of Martinique." },
  { src: "public/images/IMG_0390.jpg",  title: "Verdant Canopy",        desc: "The view from the loft, looking out into the heart of the garden." },
  { src: "public/images/IMG_0391.jpg",  title: "Artisanal Details",     desc: "Hand-crafted local timber used throughout the interior structure." },
  { src: "public/images/IMG_0392.jpg",  title: "Coastal Proximity",     desc: "Just a short walk from the cabin to the pristine Caribbean shores." },
  { src: "public/images/IMG_0396.jpg",  title: "Golden Hour",           desc: "Warm light filtering through the palm leaves at dusk." },
  { src: "public/images/IMG_0896.jpg",  title: "Botanical Sanctuary",   desc: "The private garden surrounding the A-Frame, filled with native flora." },
  { src: "public/images/IMG_0940.jpg",  title: "Morning Mist",          desc: "The cabin emerging from the mist on a humid tropical morning." },
  { src: "public/images/IMG_1251.jpg",  title: "Natural Light",         desc: "Sunlight streaming through the architectural lines of the cabin." },
  { src: "public/images/IMG_1348.jpg",  title: "Forest Serenity",       desc: "Surrounded by the tranquility of untouched tropical nature." },
  { src: "public/images/IMG_1355.jpg",  title: "Architectural Detail",  desc: "The geometric precision of the A-Frame design against natural elements." },
  { src: "public/images/IMG_3290.jpg",  title: "Tropical Flora",        desc: "The lush vegetation surrounding and embracing the structure." },
  { src: "public/images/IMG_3343.jpg",  title: "Sunset View",           desc: "The cabin silhouetted against the Caribbean sunset." },
  { src: "public/images/IMG_3936.jpg",  title: "Wooden Frame",          desc: "The structural beauty of locally sourced timber." },
  { src: "public/images/IMG_4621.JPG",  title: "Aerial View",           desc: "A panoramic view from above the cabin and surrounding forest." },
  { src: "public/images/IMG_4688.JPG",  title: "Mountain Backdrop",     desc: "The A-Frame framed against the dramatic Martinique landscape." },
  { src: "public/images/IMG_6303.jpg",  title: "Garden Path",           desc: "The winding path leading through the botanical sanctuary." },
  { src: "public/images/IMG_7953.jpg",  title: "The Domain",            desc: "The full domain — cabin, garden, and sky." },
  { src: "public/images/AA4940C0-AE7D-4C3A-8304-688BF02A1955.jpg", title: "Garden Path", desc: "Morning light on the garden path." },
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
```

- [ ] **Step 3: Delete `_layouts/post.html`**

```bash
git rm _layouts/post.html
```

- [ ] **Step 4: Add per-page scripts loop to `_layouts/default.html`** (before `</body>`, after `lang-toggle.js` script tag):

```html
  {% for script in page.scripts %}
  <script src="{{ '/assets/js/' | append: script | append: '.js' | relative_url }}"></script>
  {% endfor %}
```

- [ ] **Step 5: Commit**

```bash
git add _layouts/page.html assets/js/lightbox.js _layouts/default.html
git commit -m "feat: add page layout, extract lightbox JS, add per-page scripts support"
```

---

## Task 2: Rebuild `_includes/header.html`

**Files:**
- Modify: `_includes/header.html`

- [ ] **Step 1: Replace `_includes/header.html` entirely**

```liquid
{% assign current_lang = 'en' %}
{% if page.lang == 'fr' or page.url contains '/fr/' %}
  {% assign current_lang = 'fr' %}
{% endif %}
{% assign home_url = '/' | relative_url %}
{% assign journal_url = '/journal/' | relative_url %}
{% if current_lang == 'fr' %}
  {% assign home_url = '/fr/' | relative_url %}
  {% assign journal_url = '/fr/journal/' | relative_url %}
{% endif %}

{% assign lang_en_url = '/' | relative_url %}
{% assign lang_fr_url = '/fr/' | relative_url %}
{% if page.url == '/journal/' %}
  {% assign lang_en_url = '/journal/' | relative_url %}
  {% assign lang_fr_url = '/fr/journal/' | relative_url %}
{% elsif page.url == '/fr/journal/' %}
  {% assign lang_en_url = '/journal/' | relative_url %}
  {% assign lang_fr_url = '/fr/journal/' | relative_url %}
{% elsif page.translation_key %}
  {% for post in site.posts %}
    {% if post.translation_key == page.translation_key and post.lang != 'fr' %}
      {% assign lang_en_url = post.url | relative_url %}
    {% endif %}
  {% endfor %}
  {% for site_page in site.pages %}
    {% if site_page.translation_key == page.translation_key and site_page.lang == 'fr' %}
      {% assign lang_fr_url = site_page.url | relative_url %}
    {% endif %}
  {% endfor %}
{% endif %}

{% assign is_journal = false %}
{% if page.url == '/journal/' or page.url == '/fr/journal/' %}
  {% assign is_journal = true %}
{% endif %}

<div class="wrap">
  <header class="top-bar">
    <span class="top-left">Sainte-Luce · Martinique</span>
    <a href="{{ home_url }}" class="mark">
      <span class="ornament"></span>Les Vendredis<span class="ornament"></span>
    </a>
    <nav class="top-right">
      <a href="{{ journal_url }}"{% if is_journal %} class="active"{% endif %}>Journal</a>
      <a href="https://www.airbnb.fr/rooms/1651467419646453001?guests=1&adults=1&s=67&unique_share_id=7645a1e3-af18-41ba-ae70-2d47cedc28dd" target="_blank" rel="noopener">Réserver</a>
      <a href="https://wa.me/33666535289" target="_blank" rel="noopener">WhatsApp</a>
      <span class="lang-toggle">
        <a href="{{ lang_fr_url }}"{% if current_lang == 'fr' %} class="active"{% endif %}>FR</a>
        <a href="{{ lang_en_url }}"{% if current_lang != 'fr' %} class="active"{% endif %}>EN</a>
      </span>
    </nav>
  </header>
</div>
```

- [ ] **Step 2: Commit**

```bash
git add _includes/header.html
git commit -m "feat: rebuild header to top-bar design with correct nav links"
```

---

## Task 3: Rebuild `_includes/footer.html`

**Files:**
- Modify: `_includes/footer.html`

- [ ] **Step 1: Replace `_includes/footer.html` entirely**

```html
<div class="wrap">
  <footer class="foot">
    <span class="foot-left">© MMXXVI</span>
    <span class="foot-center">Anaïs, Bolo, Léon &amp; Samsam · Built by hand</span>
    <span class="foot-right"><a href="https://wa.me/33666535289" target="_blank" rel="noopener">WhatsApp +33 6 66 53 52 89</a></span>
  </footer>
</div>
```

- [ ] **Step 2: Commit**

```bash
git add _includes/footer.html
git commit -m "feat: rebuild footer to 3-column design matching design system"
```

---

## Task 4: Consolidate CSS into `main.css`

**Files:**
- Modify: `assets/css/main.css`

Replace the entire file with the consolidated version below. This merges all inline styles from `index.html`, deduplicates, and removes dead rules (`.site-footer`, `.site-nav`, old stale article blocks). The `.journal-head` class is replaced by `.section-head` so it can be reused for gallery and FAQ headings too.

- [ ] **Step 1: Replace `assets/css/main.css` entirely**

```css
/* ── variables ── */
:root {
  --cream:      #F8F1E4;
  --cream-soft: #F2EAD9;
  --ink:        #1F1611;
  --ink-soft:   #4A3A2D;
  --muted:      #8C7B66;
  --rule:       rgba(31,22,17,.14);
  --gold:       #B08A4D;
  --accent:     #B85F38;
  --serif:      'Cormorant Garamond', 'Times New Roman', serif;
  --sans:       'Inter Tight', ui-sans-serif, system-ui, sans-serif;
}

/* ── reset ── */
*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
html, body {
  background: var(--cream);
  color: var(--ink);
  font-family: var(--sans);
  font-weight: 300;
  -webkit-font-smoothing: antialiased;
  text-rendering: optimizeLegibility;
}
body {
  background:
    radial-gradient(ellipse 80% 60% at 50% 0%, rgba(255,240,210,.5) 0%, transparent 60%),
    var(--cream);
}
img { max-width: 100%; display: block; }
a { color: inherit; text-decoration: none; }
::selection { background: var(--accent); color: var(--cream); }
::-webkit-scrollbar { width: 5px; }
::-webkit-scrollbar-thumb { background: var(--muted); border-radius: 10px; }

/* ── layout ── */
.wrap {
  max-width: 1240px;
  margin: 0 auto;
  padding: 0 clamp(24px, 5vw, 72px);
}

/* ── header / top bar ── */
.top-bar {
  display: grid;
  grid-template-columns: 1fr auto 1fr;
  align-items: center;
  padding: 32px 0;
  gap: 24px;
  font-size: 10.5px;
  letter-spacing: .28em;
  text-transform: uppercase;
  color: var(--muted);
  font-weight: 400;
}
.top-left { justify-self: start; }
.top-right {
  justify-self: end;
  display: flex;
  gap: 28px;
  align-items: center;
}
.top-right a { transition: color .25s; }
.top-right a:hover,
.top-right a.active { color: var(--ink); }
.mark {
  justify-self: center;
  font-family: var(--serif);
  font-style: italic;
  font-size: 24px;
  letter-spacing: .01em;
  text-transform: none;
  color: var(--ink);
  font-weight: 400;
  display: flex;
  align-items: center;
  gap: 10px;
}
.ornament { width: 24px; height: 1px; background: var(--gold); opacity: .7; display: inline-block; }
.lang-toggle { display: flex; gap: 10px; border-left: 1px solid var(--rule); padding-left: 20px; }
.lang-toggle a { transition: color .25s; }
.lang-toggle a.active { color: var(--ink); }

/* ── hero ── */
.hero {
  display: grid;
  grid-template-columns: 1fr 1.05fr;
  gap: clamp(48px, 7vw, 100px);
  align-items: center;
  padding: 60px 0 100px;
}
.image-frame {
  position: relative;
  aspect-ratio: 3/4;
  overflow: hidden;
  background: var(--ink);
  box-shadow: 0 30px 60px -30px rgba(31,22,17,.35), 0 1px 0 rgba(255,255,255,.4) inset;
}
.image-frame img { width: 100%; height: 100%; object-fit: cover; }
.image-cap {
  position: absolute;
  left: 18px; bottom: 16px;
  font-family: var(--serif);
  font-style: italic;
  font-size: 14px;
  color: rgba(248,241,228,.85);
  z-index: 2;
}
.image-num {
  position: absolute;
  right: 18px; top: 18px;
  font-size: 9.5px;
  letter-spacing: .32em;
  text-transform: uppercase;
  color: rgba(248,241,228,.7);
  z-index: 2;
}
.eyebrow {
  font-size: 10.5px;
  letter-spacing: .32em;
  text-transform: uppercase;
  color: var(--gold);
  display: flex;
  align-items: center;
  gap: 14px;
  margin-bottom: 32px;
  font-weight: 500;
}
.eyebrow::before { content: ""; width: 32px; height: 1px; background: var(--gold); }
h1 {
  font-family: var(--serif);
  font-weight: 300;
  font-size: clamp(56px, 7.5vw, 108px);
  line-height: .96;
  letter-spacing: -.015em;
  margin-bottom: 32px;
}
h1 em { font-style: italic; font-weight: 400; color: var(--accent); }
.lead {
  font-family: var(--serif);
  font-size: clamp(19px, 1.5vw, 23px);
  line-height: 1.5;
  color: var(--ink-soft);
  margin-bottom: 18px;
  font-weight: 400;
}
.lead + .lead { color: var(--muted); font-style: italic; }
.ctas { display: flex; gap: 14px; margin-top: 44px; flex-wrap: wrap; align-items: center; }
.btn {
  display: inline-flex;
  align-items: center;
  gap: 14px;
  padding: 15px 26px;
  font-size: 10.5px;
  letter-spacing: .28em;
  text-transform: uppercase;
  border: 1px solid var(--ink);
  color: var(--ink);
  font-family: var(--sans);
  font-weight: 500;
  background: transparent;
  transition: all .35s ease;
}
.btn .arrow { transition: transform .35s ease; }
.btn:hover { background: var(--ink); color: var(--cream); }
.btn:hover .arrow { transform: translateX(5px); }
.btn.primary { background: var(--ink); color: var(--cream); }
.btn.primary:hover { background: var(--accent); border-color: var(--accent); }

/* ── credentials strip ── */
.creds {
  padding: 32px 0;
  border-top: 1px solid var(--rule);
  border-bottom: 1px solid var(--rule);
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 32px;
}
.cred { display: flex; flex-direction: column; gap: 6px; }
.cred .k {
  font-size: 9.5px;
  letter-spacing: .32em;
  text-transform: uppercase;
  color: var(--muted);
  font-weight: 500;
}
.cred .v {
  font-family: var(--serif);
  font-style: italic;
  font-size: 18px;
  color: var(--ink);
  font-weight: 400;
}

/* ── section heads ── */
.section-head {
  display: grid;
  grid-template-columns: 1fr 1fr;
  align-items: end;
  gap: 60px;
  margin-bottom: 64px;
}
.section-head h2 {
  font-family: var(--serif);
  font-weight: 300;
  font-size: clamp(48px, 5.5vw, 80px);
  line-height: 1;
  letter-spacing: -.015em;
}
.section-head h2 em { font-style: italic; color: var(--accent); }
.section-head .sub {
  font-family: var(--serif);
  font-size: 18px;
  color: var(--muted);
  line-height: 1.55;
  font-style: italic;
  max-width: 36ch;
}

/* ── journal ── */
.journal { padding: 120px 0 60px; }
.entry {
  display: grid;
  grid-template-columns: 160px 1fr 1.1fr;
  gap: clamp(28px, 4vw, 64px);
  padding: 48px 0;
  border-top: 1px solid var(--rule);
  align-items: start;
}
.entry:first-of-type { border-top-color: var(--ink-soft); }
.entry-meta { display: flex; flex-direction: column; gap: 10px; }
.entry-num {
  font-family: var(--serif);
  font-style: italic;
  font-size: 32px;
  color: var(--gold);
  font-weight: 400;
  line-height: 1;
}
.entry-date {
  font-family: var(--serif);
  font-style: italic;
  font-size: 16px;
  color: var(--ink);
  font-weight: 400;
}
.entry-tag {
  font-size: 9.5px;
  letter-spacing: .32em;
  text-transform: uppercase;
  color: var(--muted);
  font-weight: 500;
}
.entry-body h3 {
  font-family: var(--serif);
  font-weight: 300;
  font-size: clamp(28px, 2.6vw, 38px);
  line-height: 1.08;
  letter-spacing: -.01em;
  margin-bottom: 18px;
}
.entry-body h3 em { font-style: italic; color: var(--accent); }
.entry-body p {
  font-family: var(--serif);
  font-size: 18px;
  line-height: 1.6;
  color: var(--ink-soft);
  font-weight: 400;
}
.entry-body p + p { margin-top: 12px; }
.entry-img {
  aspect-ratio: 4/3;
  overflow: hidden;
  box-shadow: 0 20px 40px -25px rgba(31,22,17,.3);
}
.entry-img img { width: 100%; height: 100%; object-fit: cover; }
.journal-foot {
  padding: 48px 0 0;
  text-align: center;
  font-family: var(--serif);
  font-style: italic;
  font-size: 16px;
  color: var(--muted);
}
.journal-foot::before, .journal-foot::after { content: "·"; margin: 0 14px; color: var(--gold); }
.journal-foot a { border-bottom: 1px solid var(--rule); padding-bottom: 2px; transition: border-color .25s; }
.journal-foot a:hover { border-color: var(--ink); }
.read-more {
  display: inline-block;
  margin-top: 12px;
  border-bottom: 1px solid var(--rule);
  padding-bottom: 2px;
  color: var(--accent);
  font-family: var(--serif);
  font-size: 16px;
  transition: border-color .25s;
}
.read-more:hover { border-color: var(--accent); }

/* ── gallery ── */
.gallery-section { padding: 80px 0 0; border-top: 1px solid var(--rule); }
.gallery-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 16px;
  margin-bottom: 120px;
}
.gallery-item {
  position: relative;
  aspect-ratio: 3/4;
  overflow: hidden;
  background: var(--ink);
  cursor: pointer;
}
.gallery-item img {
  width: 100%; height: 100%;
  object-fit: cover;
  transition: transform .7s ease;
}
.gallery-item:hover img { transform: scale(1.05); }
.gallery-caption {
  position: absolute;
  inset: 0;
  background: linear-gradient(to top, rgba(31,22,17,.6) 0%, transparent 55%);
  opacity: 0;
  transition: opacity .4s ease;
  display: flex;
  align-items: flex-end;
  padding: 20px;
}
.gallery-item:hover .gallery-caption { opacity: 1; }
.gallery-caption span {
  font-family: var(--serif);
  font-style: italic;
  font-size: 18px;
  color: var(--cream);
}

/* ── lightbox ── */
.lightbox {
  display: none;
  position: fixed;
  inset: 0;
  z-index: 100;
  background: rgba(248,241,228,.97);
  backdrop-filter: blur(20px);
  align-items: center;
  justify-content: center;
}
.lightbox.open { display: flex; }
.lb-close, .lb-nav {
  position: absolute;
  background: none;
  border: none;
  color: var(--ink);
  opacity: .35;
  cursor: pointer;
  line-height: 1;
  transition: opacity .2s;
  font-family: var(--sans);
}
.lb-close { top: 28px; right: 28px; font-size: 24px; }
.lb-close:hover { opacity: 1; }
.lb-nav { top: 50%; transform: translateY(-50%); font-size: 36px; padding: 20px; opacity: .2; }
.lb-nav:hover { opacity: .7; }
.lb-prev { left: 16px; }
.lb-next { right: 16px; }
.lb-content {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: clamp(24px, 6vw, 96px);
  max-width: 100%;
}
.lb-img { max-width: 100%; max-height: 68vh; object-fit: contain; }
.lb-caption { margin-top: 32px; text-align: center; max-width: 560px; }
.lb-caption h3 {
  font-family: var(--serif);
  font-style: italic;
  font-weight: 400;
  font-size: clamp(22px, 2.5vw, 30px);
  color: var(--ink);
  margin-bottom: 12px;
}
.lb-caption p {
  font-family: var(--serif);
  font-size: 16px;
  line-height: 1.6;
  color: var(--muted);
  margin-top: 10px;
}
.lb-counter {
  display: block;
  margin-top: 20px;
  font-size: 10px;
  letter-spacing: .3em;
  text-transform: uppercase;
  color: var(--muted);
}

/* ── FAQ ── */
.faq-section {
  padding: 100px 0;
  border-top: 1px solid var(--rule);
}
.faq-grid {
  display: grid;
  grid-template-columns: .9fr 1.4fr;
  gap: clamp(40px, 6vw, 90px);
  align-items: start;
}
.faq-list { display: grid; gap: 18px; }
.faq-item { border-top: 1px solid var(--rule); padding-top: 18px; }
.faq-item h3 {
  font-family: var(--serif);
  font-weight: 400;
  font-size: clamp(22px, 2vw, 30px);
  line-height: 1.18;
  margin-bottom: 8px;
}
.faq-item p {
  font-family: var(--serif);
  font-size: 17px;
  line-height: 1.65;
  color: var(--ink-soft);
}

/* ── booking strip ── */
.booking {
  background: var(--ink);
  color: var(--cream);
  padding: 120px 0;
  position: relative;
  overflow: hidden;
}
.booking::before {
  content: "";
  position: absolute;
  inset: 0;
  background: radial-gradient(ellipse 70% 80% at 75% 30%, rgba(184,95,56,.15) 0%, transparent 65%);
}
.booking-inner {
  position: relative;
  z-index: 1;
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 80px;
  align-items: center;
}
.booking .eyebrow { color: var(--gold); }
.booking .eyebrow::before { background: var(--gold); }
.booking h2 {
  font-family: var(--serif);
  font-weight: 300;
  font-size: clamp(40px, 5vw, 64px);
  line-height: 1.05;
  letter-spacing: -.01em;
  color: var(--cream);
}
.booking h2 em { font-style: italic; color: var(--accent); }
.booking-sub {
  font-family: var(--serif);
  font-size: 19px;
  color: rgba(248,241,228,.7);
  margin-top: 18px;
  max-width: 42ch;
  line-height: 1.55;
  font-style: italic;
}
.b-ctas {
  display: flex;
  flex-direction: column;
  gap: 0;
  border-top: 1px solid rgba(248,241,228,.16);
}
.b-btn {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 28px 0;
  border-bottom: 1px solid rgba(248,241,228,.16);
  color: var(--cream);
  transition: all .35s ease;
}
.b-btn:hover { padding-left: 14px; padding-right: 14px; color: var(--accent); }
.b-label {
  font-family: var(--serif);
  font-style: italic;
  font-size: 32px;
  font-weight: 400;
  color: var(--cream);
  transition: color .35s;
}
.b-btn:hover .b-label { color: var(--accent); }
.b-meta {
  font-size: 10px;
  letter-spacing: .32em;
  text-transform: uppercase;
  color: rgba(248,241,228,.55);
}

/* ── article page ── */
.article-page {
  max-width: 860px;
  margin: 0 auto;
  padding: 60px clamp(24px, 5vw, 72px) 120px;
}
.article-header { margin-bottom: 60px; }
.article-breadcrumbs {
  display: flex;
  gap: 6px;
  align-items: center;
  font-size: 11px;
  letter-spacing: .16em;
  text-transform: uppercase;
  color: var(--muted);
  margin-bottom: 32px;
}
.article-breadcrumbs a { transition: color .25s; }
.article-breadcrumbs a:hover { color: var(--ink); }
.article-meta {
  display: flex;
  flex-direction: column;
  gap: 6px;
  margin-bottom: 24px;
}
.article-title {
  font-family: var(--serif);
  font-weight: 300;
  font-size: clamp(36px, 6vw, 64px);
  line-height: 1.08;
  letter-spacing: -.015em;
  margin-bottom: 20px;
}
.article-title em { font-style: italic; font-weight: 400; color: var(--accent); }
.article-summary {
  font-family: var(--serif);
  font-size: clamp(17px, 1.3vw, 20px);
  line-height: 1.5;
  color: var(--ink-soft);
  font-weight: 400;
  max-width: 600px;
}
.article-hero {
  margin: 80px 0 60px;
  aspect-ratio: 4/3;
  overflow: hidden;
  background: var(--ink);
  box-shadow: 0 30px 60px -30px rgba(31,22,17,.35);
  position: relative;
}
.article-hero img { width: 100%; height: 100%; object-fit: cover; }
.article-hero figcaption {
  font-family: var(--serif);
  font-style: italic;
  font-size: 14px;
  color: var(--muted);
  margin-top: 12px;
}
.article-body {
  font-family: var(--serif);
  font-size: 18px;
  line-height: 1.7;
  color: var(--ink);
  max-width: 720px;
  margin: 0 auto;
}
.article-body h2 {
  font-family: var(--serif);
  font-weight: 300;
  font-size: clamp(28px, 3vw, 40px);
  line-height: 1.12;
  letter-spacing: -.015em;
  margin: 48px 0 18px;
}
.article-body h2 em { font-style: italic; font-weight: 400; color: var(--accent); }
.article-body h3 {
  font-family: var(--serif);
  font-weight: 300;
  font-size: clamp(22px, 2vw, 28px);
  line-height: 1.12;
  letter-spacing: -.015em;
  margin: 32px 0 14px;
}
.article-body h3 em { font-style: italic; font-weight: 400; color: var(--accent); }
.article-body p { margin-bottom: 16px; }
.article-body p + p { margin-top: 12px; }
.article-body ul,
.article-body ol { margin: 16px 0 16px 22px; }
.article-body li { margin-bottom: 8px; }
.article-body strong { font-weight: 500; }
.article-body em:not(h2 em):not(h3 em) { font-style: italic; color: var(--accent); font-weight: 400; }

/* ── footer ── */
.foot {
  padding: 48px 0;
  display: grid;
  grid-template-columns: 1fr auto 1fr;
  align-items: center;
  gap: 24px;
  font-size: 10px;
  letter-spacing: .28em;
  text-transform: uppercase;
  color: var(--muted);
  border-top: 1px solid var(--rule);
  font-weight: 500;
}
.foot-center {
  font-family: var(--serif);
  font-style: italic;
  font-size: 14px;
  letter-spacing: .02em;
  text-transform: none;
  color: var(--ink);
  font-weight: 400;
}
.foot-left { justify-self: start; }
.foot-right { justify-self: end; }

/* ── responsive ── */
@media (max-width: 900px) {
  .top-bar { grid-template-columns: 1fr; gap: 12px; text-align: center; padding: 24px 0; }
  .top-left { display: none; }
  .top-right { justify-self: center; flex-wrap: wrap; justify-content: center; gap: 18px; }
  .hero { grid-template-columns: 1fr; gap: 40px; padding: 24px 0 60px; }
  .image-frame { aspect-ratio: 4/5; max-height: 64vh; }
  .creds { grid-template-columns: 1fr 1fr; gap: 20px; }
  .journal { padding: 80px 0 40px; }
  .section-head { grid-template-columns: 1fr; gap: 14px; margin-bottom: 40px; }
  .entry { grid-template-columns: 1fr; gap: 18px; padding: 36px 0; }
  .entry-meta { flex-direction: row; gap: 14px; align-items: baseline; flex-wrap: wrap; }
  .entry-num { font-size: 24px; }
  .gallery-grid { grid-template-columns: repeat(2, 1fr); }
  .booking { padding: 80px 0; }
  .booking-inner { grid-template-columns: 1fr; gap: 36px; }
  .faq-section { padding: 72px 0; }
  .faq-grid { grid-template-columns: 1fr; gap: 28px; }
  .b-label { font-size: 24px; }
  .foot { grid-template-columns: 1fr; text-align: center; gap: 10px; }
  .foot-left, .foot-right { justify-self: center; }
}
@media (max-width: 480px) {
  .gallery-grid { grid-template-columns: 1fr; }
  .creds { grid-template-columns: 1fr; }
}
```

- [ ] **Step 2: Commit**

```bash
git add assets/css/main.css
git commit -m "feat: consolidate all CSS into main.css, remove dead rules"
```

---

## Task 5: Create homepage includes

**Files:**
- Create: `_includes/hero.html`
- Create: `_includes/hero-fr.html`
- Create: `_includes/journal-preview.html`
- Create: `_includes/journal-preview-fr.html`
- Create: `_includes/gallery.html`
- Create: `_includes/booking.html`
- Create: `_includes/booking-fr.html`
- Create: `_includes/faq.html`
- Create: `_includes/faq-fr.html`

- [ ] **Step 1: Create `_includes/hero.html`**

```html
<div class="wrap">
  <section class="hero">
    <div class="image-frame">
      <img src="{{ '/public/images/IMG_0387.jpg' | relative_url }}" alt="A-frame cabin in Sainte-Luce, Martinique" />
      <span class="image-num">No. 01</span>
      <span class="image-cap">The cabin at golden hour</span>
    </div>
    <div>
      <div class="eyebrow">Guesthouse · Sainte-Luce, Martinique</div>
      <h1>A-frame cabin<br>in <em>Martinique.</em></h1>
      <p class="lead">A handmade A-frame cabin and a private garden in Sainte-Luce on the southern coast of Martinique.</p>
      <p class="lead">A quiet vacation rental for couples, families, and friends, three minutes from the sea on foot.</p>
      <div class="ctas">
        <a class="btn primary" href="https://www.airbnb.fr/rooms/1651467419646453001?guests=1&adults=1&s=67&unique_share_id=7645a1e3-af18-41ba-ae70-2d47cedc28dd" target="_blank" rel="noopener">Reserve on Airbnb <span class="arrow">→</span></a>
        <a class="btn" href="https://www.booking.com/hotel/mq/an-atypical-cabin.fr.html" target="_blank" rel="noopener">Booking.com <span class="arrow">→</span></a>
        <a class="btn" href="https://wa.me/33666535289?text=Hello%20Les%20Vendredis%2C%20I%27d%20like%20to%20book%20the%20cabin." target="_blank" rel="noopener">WhatsApp <span class="arrow">→</span></a>
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
```

- [ ] **Step 2: Create `_includes/hero-fr.html`**

```html
<div class="wrap">
  <section class="hero">
    <div class="image-frame">
      <img src="{{ '/public/images/IMG_0387.jpg' | relative_url }}" alt="Cabane A-frame à Sainte-Luce, Martinique" />
      <span class="image-num">No. 01</span>
      <span class="image-cap">La cabane à l'heure dorée</span>
    </div>
    <div>
      <div class="eyebrow">Maison d'hôtes · Sainte-Luce, Martinique</div>
      <h1>Cabane A-frame<br>en <em>Martinique.</em></h1>
      <p class="lead">Une cabane A-frame artisanale et un jardin privé à Sainte-Luce, sur la côte sud de la Martinique.</p>
      <p class="lead">Une location de vacances tranquille pour couples, familles et amis, à trois minutes de la mer à pied.</p>
      <div class="ctas">
        <a class="btn primary" href="https://www.airbnb.fr/rooms/1651467419646453001?guests=1&adults=1&s=67&unique_share_id=7645a1e3-af18-41ba-ae70-2d47cedc28dd" target="_blank" rel="noopener">Réserver sur Airbnb <span class="arrow">→</span></a>
        <a class="btn" href="https://www.booking.com/hotel/mq/an-atypical-cabin.fr.html" target="_blank" rel="noopener">Booking.com <span class="arrow">→</span></a>
        <a class="btn" href="https://wa.me/33666535289?text=Bonjour%20Les%20Vendredis%2C%20je%20voudrais%20r%C3%A9server%20la%20cabane." target="_blank" rel="noopener">WhatsApp <span class="arrow">→</span></a>
      </div>
    </div>
  </section>
  <div class="creds">
    <div class="cred"><span class="k">Lieu</span><span class="v">Sainte-Luce</span></div>
    <div class="cred"><span class="k">Construit</span><span class="v">À la main · 2022—2024</span></div>
    <div class="cred"><span class="k">Capacité</span><span class="v">Deux adultes &amp; un enfant</span></div>
    <div class="cred"><span class="k">La mer</span><span class="v">Trois minutes à pied</span></div>
  </div>
</div>
```

- [ ] **Step 3: Create `_includes/journal-preview.html`**

```liquid
<div class="wrap">
  <section class="journal" id="journal">
    <div class="section-head">
      <h2>The <em>journal.</em></h2>
      <p class="sub">Notes from the build, the garden, and the slow life of Sainte-Luce. Updated by the family.</p>
    </div>
    {% assign english_posts = site.posts | where_exp: "post", "post.lang != 'fr'" %}
    {% if english_posts.size == 0 %}{% assign english_posts = site.posts %}{% endif %}
    {% for post in english_posts limit: 3 %}
    <article class="entry">
      <div class="entry-meta">
        {% assign post_num = english_posts.size | minus: forloop.index0 %}
        <span class="entry-num">{% include roman.html number=post_num %}</span>
        <span class="entry-date">{{ post.date | date: "%A, %B %-d %Y" }}</span>
        <span class="entry-tag">{{ post.tag }}</span>
      </div>
      <div class="entry-body">
        <h3><a href="{{ post.url | relative_url }}">{{ post.title }}</a></h3>
        <p>{{ post.summary | truncate: 160 }}</p>
      </div>
      <div class="entry-img">
        {% if post.image %}<img src="{{ '/public/images/' | append: post.image | relative_url }}" alt="{{ post.image_alt | default: post.title }}" loading="lazy" />{% endif %}
      </div>
    </article>
    {% endfor %}
    <div class="journal-foot"><a href="{{ '/journal/' | relative_url }}">See all entries →</a></div>
  </section>
</div>
```

- [ ] **Step 4: Create `_includes/journal-preview-fr.html`**

```liquid
<div class="wrap">
  <section class="journal" id="journal">
    <div class="section-head">
      <h2>Le <em>journal.</em></h2>
      <p class="sub">Notes du chantier, du jardin et de la vie lente à Sainte-Luce. Mis à jour par la famille.</p>
    </div>
    {% assign french_posts = site.pages | where_exp: "post", "post.lang == 'fr' and post.layout == 'article'" | sort: "date" | reverse %}
    {% for post in french_posts limit: 3 %}
    <article class="entry">
      <div class="entry-meta">
        {% assign post_num = french_posts.size | minus: forloop.index0 %}
        <span class="entry-num">{% include roman.html number=post_num %}</span>
        <span class="entry-date">{{ post.date | date: "%-d %B %Y" }}</span>
        <span class="entry-tag">{{ post.tag }}</span>
      </div>
      <div class="entry-body">
        <h3><a href="{{ post.url | relative_url }}">{{ post.title }}</a></h3>
        <p>{{ post.summary | truncate: 160 }}</p>
      </div>
      <div class="entry-img">
        {% if post.image %}<img src="{{ '/public/images/' | append: post.image | relative_url }}" alt="{{ post.image_alt | default: post.title }}" loading="lazy" />{% endif %}
      </div>
    </article>
    {% endfor %}
    <div class="journal-foot"><a href="{{ '/fr/journal/' | relative_url }}">Voir tous les articles →</a></div>
  </section>
</div>
```

- [ ] **Step 5: Create `_includes/gallery.html`**

```html
<div class="wrap" id="gallery">
  <section class="gallery-section">
    <div class="section-head">
      <h2>The <em>place.</em></h2>
      <p class="sub">Views of the cabin, the garden, and the land we built from scratch.</p>
    </div>
    <div class="gallery-grid">
      <div class="gallery-item" onclick="openLightbox(0)"><img src="{{ '/public/images/IMG_0387.jpg' | relative_url }}" alt="The A-Frame Exterior" loading="lazy" /><div class="gallery-caption"><span>The A-Frame Exterior</span></div></div>
      <div class="gallery-item" onclick="openLightbox(1)"><img src="{{ '/public/images/IMG_0390.jpg' | relative_url }}" alt="Verdant Canopy" loading="lazy" /><div class="gallery-caption"><span>Verdant Canopy</span></div></div>
      <div class="gallery-item" onclick="openLightbox(2)"><img src="{{ '/public/images/IMG_0391.jpg' | relative_url }}" alt="Artisanal Details" loading="lazy" /><div class="gallery-caption"><span>Artisanal Details</span></div></div>
      <div class="gallery-item" onclick="openLightbox(3)"><img src="{{ '/public/images/IMG_0392.jpg' | relative_url }}" alt="Coastal Proximity" loading="lazy" /><div class="gallery-caption"><span>Coastal Proximity</span></div></div>
      <div class="gallery-item" onclick="openLightbox(4)"><img src="{{ '/public/images/IMG_0396.jpg' | relative_url }}" alt="Golden Hour" loading="lazy" /><div class="gallery-caption"><span>Golden Hour</span></div></div>
      <div class="gallery-item" onclick="openLightbox(5)"><img src="{{ '/public/images/IMG_0896.jpg' | relative_url }}" alt="Botanical Sanctuary" loading="lazy" /><div class="gallery-caption"><span>Botanical Sanctuary</span></div></div>
      <div class="gallery-item" onclick="openLightbox(6)"><img src="{{ '/public/images/IMG_0940.jpg' | relative_url }}" alt="Morning Mist" loading="lazy" /><div class="gallery-caption"><span>Morning Mist</span></div></div>
      <div class="gallery-item" onclick="openLightbox(7)"><img src="{{ '/public/images/IMG_1251.jpg' | relative_url }}" alt="Natural Light" loading="lazy" /><div class="gallery-caption"><span>Natural Light</span></div></div>
      <div class="gallery-item" onclick="openLightbox(8)"><img src="{{ '/public/images/IMG_1348.jpg' | relative_url }}" alt="Forest Serenity" loading="lazy" /><div class="gallery-caption"><span>Forest Serenity</span></div></div>
      <div class="gallery-item" onclick="openLightbox(9)"><img src="{{ '/public/images/IMG_1355.jpg' | relative_url }}" alt="Architectural Detail" loading="lazy" /><div class="gallery-caption"><span>Architectural Detail</span></div></div>
      <div class="gallery-item" onclick="openLightbox(10)"><img src="{{ '/public/images/IMG_3290.jpg' | relative_url }}" alt="Tropical Flora" loading="lazy" /><div class="gallery-caption"><span>Tropical Flora</span></div></div>
      <div class="gallery-item" onclick="openLightbox(11)"><img src="{{ '/public/images/IMG_3343.jpg' | relative_url }}" alt="Sunset View" loading="lazy" /><div class="gallery-caption"><span>Sunset View</span></div></div>
      <div class="gallery-item" onclick="openLightbox(12)"><img src="{{ '/public/images/IMG_3936.jpg' | relative_url }}" alt="Wooden Frame" loading="lazy" /><div class="gallery-caption"><span>Wooden Frame</span></div></div>
      <div class="gallery-item" onclick="openLightbox(13)"><img src="{{ '/public/images/IMG_4621.JPG' | relative_url }}" alt="Aerial View" loading="lazy" /><div class="gallery-caption"><span>Aerial View</span></div></div>
      <div class="gallery-item" onclick="openLightbox(14)"><img src="{{ '/public/images/IMG_4688.JPG' | relative_url }}" alt="Mountain Backdrop" loading="lazy" /><div class="gallery-caption"><span>Mountain Backdrop</span></div></div>
      <div class="gallery-item" onclick="openLightbox(15)"><img src="{{ '/public/images/IMG_6303.jpg' | relative_url }}" alt="Garden Path" loading="lazy" /><div class="gallery-caption"><span>Garden Path</span></div></div>
      <div class="gallery-item" onclick="openLightbox(16)"><img src="{{ '/public/images/IMG_7953.jpg' | relative_url }}" alt="The Domain" loading="lazy" /><div class="gallery-caption"><span>The Domain</span></div></div>
      <div class="gallery-item" onclick="openLightbox(17)"><img src="{{ '/public/images/AA4940C0-AE7D-4C3A-8304-688BF02A1955.jpg' | relative_url }}" alt="Garden Path" loading="lazy" /><div class="gallery-caption"><span>Garden Path</span></div></div>
    </div>
  </section>
</div>

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
```

- [ ] **Step 6: Create `_includes/booking.html`**

```html
<section class="booking" id="stay">
  <div class="wrap booking-inner">
    <div>
      <div class="eyebrow">Reservations</div>
      <h2>Come stay in <em>our Friday.</em></h2>
      <p class="booking-sub">Listed on Airbnb and Booking.com. The cabin and the welcome are the same — choose the platform you prefer.</p>
    </div>
    <div class="b-ctas">
      <a class="b-btn" href="https://www.airbnb.fr/rooms/1651467419646453001?guests=1&adults=1&s=67&unique_share_id=7645a1e3-af18-41ba-ae70-2d47cedc28dd" target="_blank" rel="noopener"><span class="b-label">Airbnb</span><span class="b-meta">Open ↗</span></a>
      <a class="b-btn" href="https://www.booking.com/hotel/mq/an-atypical-cabin.fr.html" target="_blank" rel="noopener"><span class="b-label">Booking.com</span><span class="b-meta">Open ↗</span></a>
      <a class="b-btn" href="https://wa.me/33666535289?text=Hello%20Les%20Vendredis%2C%20I%27d%20like%20to%20book%20the%20cabin." target="_blank" rel="noopener"><span class="b-label">WhatsApp</span><span class="b-meta">Message us ↗</span></a>
    </div>
  </div>
</section>
```

- [ ] **Step 7: Create `_includes/booking-fr.html`**

```html
<section class="booking" id="reserver">
  <div class="wrap booking-inner">
    <div>
      <div class="eyebrow">Réservations</div>
      <h2>Venez passer <em>votre vendredi.</em></h2>
      <p class="booking-sub">Disponible sur Airbnb et Booking.com. La cabane et l'accueil sont les mêmes — choisissez la plateforme que vous préférez.</p>
    </div>
    <div class="b-ctas">
      <a class="b-btn" href="https://www.airbnb.fr/rooms/1651467419646453001?guests=1&adults=1&s=67&unique_share_id=7645a1e3-af18-41ba-ae70-2d47cedc28dd" target="_blank" rel="noopener"><span class="b-label">Airbnb</span><span class="b-meta">Ouvrir ↗</span></a>
      <a class="b-btn" href="https://www.booking.com/hotel/mq/an-atypical-cabin.fr.html" target="_blank" rel="noopener"><span class="b-label">Booking.com</span><span class="b-meta">Ouvrir ↗</span></a>
      <a class="b-btn" href="https://wa.me/33666535289?text=Bonjour%20Les%20Vendredis%2C%20je%20voudrais%20r%C3%A9server%20la%20cabane." target="_blank" rel="noopener"><span class="b-label">WhatsApp</span><span class="b-meta">Nous écrire ↗</span></a>
    </div>
  </div>
</section>
```

- [ ] **Step 8: Create `_includes/faq.html`**

```html
<div class="wrap">
  <section class="faq-section" aria-labelledby="faq-title">
    <div class="faq-grid">
      <div>
        <h2 id="faq-title">Good to <em>know.</em></h2>
        <p class="sub" style="margin-top:18px;">Practical details for finding, booking, and staying at Les Vendredis.</p>
      </div>
      <div class="faq-list">
        <div class="faq-item"><h3>Where is Les Vendredis located?</h3><p>Les Vendredis is located in Sainte-Luce on the south coast of Martinique.</p></div>
        <div class="faq-item"><h3>How close is Les Vendredis to the beach?</h3><p>The cabin is three minutes from the Sainte-Luce coast on foot.</p></div>
        <div class="faq-item"><h3>How do I book Les Vendredis?</h3><p>You can book on Airbnb or Booking.com, or contact us on WhatsApp at +33 6 66 53 52 89.</p></div>
        <div class="faq-item"><h3>How many guests can stay?</h3><p>Les Vendredis sleeps two adults and one child.</p></div>
        <div class="faq-item"><h3>Does Les Vendredis have a garden?</h3><p>Yes. A private tropical garden with mango trees, bougainvillea, and planted paths.</p></div>
        <div class="faq-item"><h3>What is Sainte-Luce?</h3><p>Sainte-Luce is a village on the south coast of Martinique, a French Caribbean island.</p></div>
      </div>
    </div>
  </section>
</div>
```

- [ ] **Step 9: Create `_includes/faq-fr.html`**

```html
<div class="wrap">
  <section class="faq-section" aria-labelledby="faq-title-fr">
    <div class="faq-grid">
      <div>
        <h2 id="faq-title-fr">Bon à <em>savoir.</em></h2>
        <p class="sub" style="margin-top:18px;">Tout ce qu'il faut savoir pour trouver, réserver et séjourner aux Vendredis.</p>
      </div>
      <div class="faq-list">
        <div class="faq-item"><h3>Où se trouvent Les Vendredis ?</h3><p>Les Vendredis se trouvent à Sainte-Luce, sur la côte sud de la Martinique.</p></div>
        <div class="faq-item"><h3>À quelle distance est la mer ?</h3><p>La cabane est à trois minutes de la côte de Sainte-Luce à pied.</p></div>
        <div class="faq-item"><h3>Comment réserver Les Vendredis ?</h3><p>Sur Airbnb ou Booking.com, ou par WhatsApp au +33 6 66 53 52 89.</p></div>
        <div class="faq-item"><h3>Combien de personnes peut accueillir la cabane ?</h3><p>Les Vendredis accueille deux adultes et un enfant.</p></div>
        <div class="faq-item"><h3>Y a-t-il un jardin ?</h3><p>Oui. Un jardin tropical privé avec des manguiers, des bougainvillées et des allées plantées.</p></div>
        <div class="faq-item"><h3>C'est quoi Sainte-Luce ?</h3><p>Sainte-Luce est un bourg sur la côte sud de la Martinique, une île française des Caraïbes.</p></div>
      </div>
    </div>
  </section>
</div>
```

- [ ] **Step 10: Commit**

```bash
git add _includes/
git commit -m "feat: create all homepage includes (hero, journal-preview, gallery, booking, faq)"
```

---

## Task 6: Convert `index.html` to Jekyll page

**Files:**
- Modify: `index.html`

- [ ] **Step 1: Replace `index.html` entirely**

```liquid
---
layout: page
title: "Les Vendredis"
seo_title: "A-frame cabin in Sainte-Luce, Martinique | Les Vendredis"
description: "Book a handmade A-frame cabin with a private garden in Sainte-Luce, Martinique. A quiet vacation rental on the south coast, with Airbnb and Booking.com links."
lang: en
canonical_url: https://lesvendredis.casa/
scripts:
  - lightbox
---

{% include hero.html %}
{% include journal-preview.html %}
{% include gallery.html %}
{% include faq.html %}
{% include booking.html %}
```

- [ ] **Step 2: Build and verify**

```bash
bundle exec jekyll build 2>&1 | tail -5
```

Expected: `done in X seconds` with no errors.

- [ ] **Step 3: Commit**

```bash
git add index.html
git commit -m "feat: convert index.html to Jekyll page using includes"
```

---

## Task 7: Convert `fr/index.html` to Jekyll page

**Files:**
- Modify: `fr/index.html`

- [ ] **Step 1: Replace `fr/index.html` entirely**

```liquid
---
layout: page
title: "Les Vendredis"
seo_title: "Cabane A-frame à Sainte-Luce, Martinique | Les Vendredis"
description: "Réservez une cabane A-frame artisanale avec jardin privé à Sainte-Luce, Martinique. Location de vacances tranquille sur la côte sud."
lang: fr
canonical_url: https://lesvendredis.casa/fr/
permalink: /fr/
scripts:
  - lightbox
---

{% include hero-fr.html %}
{% include journal-preview-fr.html %}
{% include gallery.html %}
{% include faq-fr.html %}
{% include booking-fr.html %}
```

- [ ] **Step 2: Build and verify**

```bash
bundle exec jekyll build 2>&1 | tail -5
```

- [ ] **Step 3: Commit**

```bash
git add fr/index.html
git commit -m "feat: convert fr/index.html to Jekyll page"
```

---

## Task 8: Clean up journal pages and delete dead files

**Files:**
- Modify: `journal/index.html`
- Modify: `fr/journal/index.html`
- Delete: `journal.html`, `articles/index.html`

- [ ] **Step 1: Replace `journal/index.html`**

```liquid
---
layout: default
seo_title: "Journal"
title: "Journal"
description: "A complete archive of journal entries from Sainte-Luce, Martinique."
lang: "en"
---

<div class="wrap">
  <section class="journal">
    <div class="section-head">
      <h2>All <em>Entries.</em></h2>
      <p class="sub">A complete archive of the journal, from newest to oldest.</p>
    </div>
    <div class="journal-entries">
      {% assign english_posts = site.posts | where_exp: "post", "post.lang != 'fr'" %}
      {% if english_posts.size == 0 %}{% assign english_posts = site.posts %}{% endif %}
      {% for post in english_posts %}
      <article class="entry">
        <div class="entry-meta">
          {% assign post_num = english_posts.size | minus: forloop.index0 %}
          <span class="entry-num">{% include roman.html number=post_num %}</span>
          <span class="entry-date">{{ post.date | date: "%B %-d, %Y" }}</span>
          <span class="entry-tag">{{ post.tag }}</span>
        </div>
        <div class="entry-body">
          <h3><a href="{{ post.url | relative_url }}">{{ post.title }}</a></h3>
          <p>{{ post.summary }}</p>
          <a href="{{ post.url | relative_url }}" class="read-more">Read more →</a>
        </div>
        <div class="entry-img">
          {% if post.image %}<img src="{{ '/public/images/' | append: post.image | relative_url }}" alt="{{ post.image_alt }}" loading="lazy" />{% endif %}
        </div>
      </article>
      {% endfor %}
    </div>
  </section>
</div>
```

- [ ] **Step 2: Replace `fr/journal/index.html`**

```liquid
---
layout: default
seo_title: "Journal français"
title: "Journal français"
description: "Une archive en français des notes du chantier, du jardin et de la vie à Sainte-Luce."
lang: "fr"
permalink: /fr/journal/
canonical_url: https://lesvendredis.casa/fr/journal/
---

<div class="wrap">
  <section class="journal">
    <div class="section-head">
      <h2>Journal <em>français.</em></h2>
      <p class="sub">Les notes du chantier, du jardin et de la vie lente à Sainte-Luce.</p>
    </div>
    <div class="journal-entries">
      {% assign french_posts = site.pages | where_exp: "post", "post.lang == 'fr' and post.layout == 'article'" | sort: "date" | reverse %}
      {% for post in french_posts %}
      <article class="entry">
        <div class="entry-meta">
          {% assign post_num = french_posts.size | minus: forloop.index0 %}
          <span class="entry-num">{% include roman.html number=post_num %}</span>
          <span class="entry-date">{{ post.date | date: "%-d %B %Y" }}</span>
          <span class="entry-tag">{{ post.tag }}</span>
        </div>
        <div class="entry-body">
          <h3><a href="{{ post.url | relative_url }}">{{ post.title }}</a></h3>
          <p>{{ post.summary }}</p>
          <a href="{{ post.url | relative_url }}" class="read-more">Lire →</a>
        </div>
        <div class="entry-img">
          {% if post.image %}<img src="{{ '/public/images/' | append: post.image | relative_url }}" alt="{{ post.image_alt }}" loading="lazy" />{% endif %}
        </div>
      </article>
      {% endfor %}
    </div>
  </section>
</div>
```

- [ ] **Step 3: Delete dead files**

```bash
git rm journal.html articles/index.html
```

- [ ] **Step 4: Build and verify**

```bash
bundle exec jekyll build 2>&1 | tail -5
```

Expected: no errors.

- [ ] **Step 5: Commit**

```bash
git add journal/index.html fr/journal/index.html
git commit -m "feat: clean journal pages, delete dead redirect files"
```

---

## Task 9: Final build and smoke test

- [ ] **Step 1: Full build**

```bash
bundle exec jekyll build 2>&1
```

Expected: 0 errors, 0 warnings about missing files.

- [ ] **Step 2: Serve and manually verify**

```bash
bundle exec jekyll serve --port 4000
```

Visit and confirm:
- `http://localhost:4000/` — hero, journal preview, gallery, FAQ, booking strip; shared header/footer
- `http://localhost:4000/journal/` — full entry list; same header/footer
- `http://localhost:4000/journal/the-next-generation-builders/` — article with breadcrumbs
- `http://localhost:4000/fr/` — French homepage
- `http://localhost:4000/fr/journal/` — French journal index
- Nav "Journal" → `/journal/` (not `/#journal`)
- Nav "Réserver" → Airbnb, new tab
- Lightbox works on homepage, not loaded on other pages
- Header and footer identical on all pages

- [ ] **Step 3: Final commit**

```bash
git add -A
git commit -m "feat: complete Jekyll unification — one layout, one CSS, shared header/footer"
```
