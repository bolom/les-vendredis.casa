# Mobile Story Booking Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the mobile homepage story-first while keeping Airbnb booking persistently available as the only primary action.

**Architecture:** Keep the static Jekyll include structure. Add a small homepage-only sticky booking include rendered from the default layout, update hero/booking markup to clarify Airbnb as action and WhatsApp as contact, and use CSS media queries for the mobile-first presentation.

**Tech Stack:** Jekyll/Liquid includes, static HTML, CSS, existing JavaScript only.

---

## File Structure

- Create `_includes/sticky-booking.html`: homepage-only mobile sticky booking bar with language-aware copy and Airbnb link.
- Modify `_layouts/default.html`: render the sticky booking include once after the footer for home pages.
- Modify `_includes/header.html`: remove the mobile home-page booking link so the sticky bar is the only persistent home CTA.
- Modify `_includes/hero.html`: add mobile sensory cues and separate the secondary family note from the first lead.
- Modify `_includes/hero-fr.html`: French equivalent of the hero cue/note markup.
- Modify `_includes/booking.html`: make Airbnb primary and WhatsApp a secondary contact link.
- Modify `_includes/booking-fr.html`: French equivalent of final booking hierarchy.
- Modify `assets/css/main.css`: mobile hero postcard treatment, sensory strip, sticky booking bar, and secondary WhatsApp styling.

---

### Task 1: Add Homepage Sticky Booking Include

**Files:**
- Create: `_includes/sticky-booking.html`
- Modify: `_layouts/default.html`
- Modify: `_includes/header.html`

- [ ] **Step 1: Add the include**

Create `_includes/sticky-booking.html` with:

```liquid
{% assign current_lang = 'en' %}
{% if page.lang == 'fr' or page.url contains '/fr/' %}
  {% assign current_lang = 'fr' %}
{% endif %}

{% assign is_home = false %}
{% if page.url == '/' or page.url == '/fr/' or page.url == '/index.html' or page.url == '/fr/index.html' %}
  {% assign is_home = true %}
{% endif %}

{% if is_home %}
<div class="sticky-booking" aria-label="{% if current_lang == 'fr' %}Réservation{% else %}Booking{% endif %}">
  <span class="sticky-booking-text">{% if current_lang == 'fr' %}Séjourner aux Vendredis{% else %}Stay at Les Vendredis{% endif %}</span>
  <a class="sticky-booking-btn" href="https://airbnb.fr/h/lesvendredis" target="_blank" rel="noopener">{% if current_lang == 'fr' %}Réserver{% else %}Book{% endif %}</a>
</div>
{% endif %}
```

- [ ] **Step 2: Render it from the default layout**

In `_layouts/default.html`, after `{% include footer.html %}`, add:

```liquid
  {% include sticky-booking.html %}
```

- [ ] **Step 3: Verify Liquid renders the include**

In `_includes/header.html`, replace the homepage/mobile reserve link branch with an interior-page-only link:

```liquid
        {% unless is_home %}
        <a class="mobile-show reserve-link" href="https://airbnb.fr/h/lesvendredis" target="_blank" rel="noopener">{% if current_lang == 'fr' %}Réserver{% else %}Book{% endif %}</a>
        {% endunless %}
```

- [ ] **Step 4: Verify Liquid renders the include**

Run: `rbenv exec bundle exec jekyll build`

Expected: build exits with code 0 and generated home pages contain `class="sticky-booking"`.

---

### Task 2: Rework Mobile Hero Markup

**Files:**
- Modify: `_includes/hero.html`
- Modify: `_includes/hero-fr.html`

- [ ] **Step 1: Update English hero content structure**

In `_includes/hero.html`, replace the two lead paragraphs and CTA block with:

```html
      <p class="lead hero-primary-lead">An A-frame, a covered <em>préau</em>, a fruit garden, and hammocks in the hills of Sainte-Luce.</p>
      <div class="hero-sensory" aria-label="Place cues">
        <span>Garden</span>
        <span>Préau</span>
        <span>Hammocks</span>
        <span>Quiet hills</span>
      </div>
      <p class="lead hero-family-note">Les Vendredis is our family place, open when we're away — for guests who love simple, personal, un-standardised places.</p>
      <div class="ctas hero-ctas">
        <a class="btn primary" href="https://airbnb.fr/h/lesvendredis" target="_blank" rel="noopener">Book on Airbnb <span class="arrow">→</span></a>
        <a class="btn subtle" href="#gallery">See the place <span class="arrow">→</span></a>
      </div>
```

- [ ] **Step 2: Update French hero content structure**

In `_includes/hero-fr.html`, replace the two lead paragraphs and CTA block with:

```html
      <p class="lead hero-primary-lead">Une A-frame, un préau, un jardin fruitier et des hamacs dans les hauteurs de Sainte-Luce.</p>
      <div class="hero-sensory" aria-label="Repères du lieu">
        <span>Jardin</span>
        <span>Préau</span>
        <span>Hamacs</span>
        <span>Hauteurs calmes</span>
      </div>
      <p class="lead hero-family-note">Les Vendredis est notre lieu de famille, ouvert quand nous n'y sommes pas — pour ceux qui aiment les endroits simples, personnels et non standardisés.</p>
      <div class="ctas hero-ctas">
        <a class="btn primary" href="https://airbnb.fr/h/lesvendredis" target="_blank" rel="noopener">Réserver sur Airbnb <span class="arrow">→</span></a>
        <a class="btn subtle" href="#gallery">Voir le lieu <span class="arrow">→</span></a>
      </div>
```

- [ ] **Step 3: Verify anchors exist**

Run: `rg -n 'id="gallery"|hero-sensory|hero-family-note' _includes assets/css/main.css`

Expected: `hero-sensory` and `hero-family-note` exist in both hero includes, and `id="gallery"` exists in the gallery include.

---

### Task 3: Clarify Final Booking Hierarchy

**Files:**
- Modify: `_includes/booking.html`
- Modify: `_includes/booking-fr.html`

- [ ] **Step 1: Update English booking copy and CTA classes**

In `_includes/booking.html`, change the booking paragraph to:

```html
      <p class="booking-sub">You come to live our family place when we're away: a simple, personal spot open to the garden. Airbnb is the booking path; WhatsApp is there if you want to ask a direct question before deciding.</p>
```

Replace the second WhatsApp CTA anchor class from `class="b-btn"` to:

```html
class="b-btn b-btn-secondary"
```

- [ ] **Step 2: Update French booking copy and CTA classes**

In `_includes/booking-fr.html`, change the booking paragraph to:

```html
      <p class="booking-sub">Vous venez vivre notre lieu de famille quand nous n'y sommes pas : un endroit simple, personnel, ouvert sur le jardin. Airbnb est le chemin de réservation ; WhatsApp reste là pour poser une question directe avant de décider.</p>
```

Replace the second WhatsApp CTA anchor class from `class="b-btn"` to:

```html
class="b-btn b-btn-secondary"
```

- [ ] **Step 3: Verify hierarchy in markup**

Run: `rg -n 'b-btn-secondary|Airbnb is the booking path|Airbnb est le chemin' _includes/booking*.html`

Expected: both booking includes have one secondary WhatsApp CTA and updated explanatory copy.

---

### Task 4: Add Mobile-First CSS

**Files:**
- Modify: `assets/css/main.css`

- [ ] **Step 1: Add base styles for new elements**

Add before the responsive section:

```css
.hero-sensory {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin: 24px 0 18px;
}
.hero-sensory span {
  border: 1px solid var(--rule);
  padding: 8px 10px;
  font-size: 10px;
  letter-spacing: .18em;
  text-transform: uppercase;
  color: var(--ink-soft);
  background: rgba(248,241,228,.48);
}
.btn.subtle {
  border-color: var(--rule);
  color: var(--ink-soft);
}
.btn.subtle:hover {
  border-color: var(--ink);
}
.b-btn-secondary .b-label {
  color: rgba(248,241,228,.72);
}
.b-btn-secondary .b-note,
.b-btn-secondary .b-meta {
  color: rgba(248,241,228,.45);
}
.sticky-booking {
  display: none;
}
```

- [ ] **Step 2: Add mobile sticky bar and postcard refinements**

Inside `@media (max-width: 900px)`, add:

```css
  body:has(.sticky-booking) {
    padding-bottom: calc(76px + env(safe-area-inset-bottom));
  }
  .hero {
    padding-top: 18px;
  }
  .hero > .image-frame {
    margin-left: -20px;
    margin-right: -20px;
    width: calc(100% + 40px);
    aspect-ratio: 4 / 3;
  }
  .hero-primary-lead {
    font-size: 20px;
  }
  .hero-family-note {
    padding-top: 18px;
    border-top: 1px solid var(--rule);
  }
  .hero-sensory {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 8px;
    margin: 22px 0;
  }
  .hero-sensory span {
    min-height: 40px;
    display: flex;
    align-items: center;
  }
  .hero-ctas .btn.subtle {
    order: -1;
  }
  .sticky-booking {
    position: fixed;
    left: 12px;
    right: 12px;
    bottom: calc(10px + env(safe-area-inset-bottom));
    z-index: 80;
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 14px;
    min-height: 58px;
    padding: 10px 10px 10px 16px;
    background: rgba(31,22,17,.94);
    color: var(--cream);
    box-shadow: 0 18px 38px -18px rgba(31,22,17,.55);
    backdrop-filter: saturate(140%) blur(12px);
    -webkit-backdrop-filter: saturate(140%) blur(12px);
  }
  .sticky-booking-text {
    min-width: 0;
    font-family: var(--serif);
    font-style: italic;
    font-size: 17px;
    line-height: 1.1;
    color: rgba(248,241,228,.86);
  }
  .sticky-booking-btn {
    flex: 0 0 auto;
    min-height: 38px;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    padding: 0 16px;
    background: var(--cream);
    color: var(--ink);
    font-size: 10px;
    letter-spacing: .18em;
    text-transform: uppercase;
    font-weight: 600;
  }
  .b-btn-secondary {
    padding-top: 22px;
    padding-bottom: 22px;
  }
```

- [ ] **Step 3: Add narrow-phone adjustment**

Inside `@media (max-width: 480px)`, add:

```css
  .sticky-booking {
    left: 10px;
    right: 10px;
  }
  .sticky-booking-text {
    font-size: 16px;
  }
```

- [ ] **Step 4: Verify CSS syntax with build**

Run: `rbenv exec bundle exec jekyll build`

Expected: build exits with code 0.

---

### Task 5: Manual Responsive Verification

**Files:**
- No source changes expected

- [ ] **Step 1: Start local server**

Run: `rbenv exec bundle exec jekyll serve --host 127.0.0.1 --port 4000`

Expected: server starts and serves `http://127.0.0.1:4000/`.

- [ ] **Step 2: Inspect mobile homepage**

Open or screenshot `http://127.0.0.1:4000/fr/` at a mobile viewport around 390x844.

Expected:

- First viewport is image and story-led.
- Sticky booking bar is visible near the bottom.
- Sticky bar has one primary action: `Réserver`.
- No WhatsApp button appears in the sticky bar.
- Page content is not hidden behind the sticky bar.

- [ ] **Step 3: Inspect desktop homepage**

Open or screenshot `http://127.0.0.1:4000/` at a desktop viewport around 1365x900.

Expected:

- Sticky booking bar is hidden.
- Desktop hero remains coherent.
- Final booking section shows Airbnb as primary and WhatsApp as quieter contact.

- [ ] **Step 4: Commit implementation**

Run:

```bash
git add _includes/sticky-booking.html _layouts/default.html _includes/hero.html _includes/hero-fr.html _includes/booking.html _includes/booking-fr.html assets/css/main.css docs/superpowers/plans/2026-05-13-mobile-story-booking.md
git commit -m "feat: improve mobile story booking ux"
```

Expected: commit succeeds with the implementation and plan.

---

## Self-Review

- Spec coverage: sticky mobile booking bar, Airbnb-only primary action, WhatsApp secondary treatment, story-first mobile hero, and desktop preservation are covered.
- Placeholder scan: no placeholders remain.
- Type/name consistency: CSS classes introduced in markup are defined in the CSS task.
