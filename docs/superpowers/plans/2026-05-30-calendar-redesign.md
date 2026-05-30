# Calendar Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remplacer le calendrier 3-mois en grille dense par un calendrier grand format (1 mois, navigation flèches, états typographiques) et retravailler les pages "Come stay" et `/come-stay/`.

**Architecture:** On refactorise `availability.js` pour gérer un mois courant avec état de navigation + nouveau rendu HTML typographique. Le CSS existant `.cal-*` est remplacé entièrement. Les HTML des sections booking et manifesto sont restructurés.

**Tech Stack:** Vanilla JS (IIFE existant), CSS variables existantes (`--accent`, `--serif`, `--ink`, `--muted`, `--rule`), Jekyll Liquid, bilingue EN/FR.

---

## Fichiers touchés

| Fichier | Action |
|---------|--------|
| `assets/js/availability.js` | Réécriture : mois unique, navigation, rendu typographique |
| `assets/css/main.css` | Remplacer bloc `.cal-*` + refonte `.come-stay*` |
| `_includes/booking.html` | Nouvelle structure section homepage EN |
| `_includes/booking-fr.html` | Nouvelle structure section homepage FR |
| `come-stay.html` | Déplacer calendrier avant CTA, resserrer |
| `fr/venir-dormir.html` | Même chose en FR |

---

### Task 1 : Réécriture de `availability.js`

**Files:**
- Modify: `assets/js/availability.js`

Le nouveau JS gère :
- `currentOffset` (0, 1, ou 2) = mois courant affiché par rapport au mois en cours
- Fetch une seule fois les 3 mois, navigation en mémoire
- Rendu : titre géant, flèches, grille, point terracotta sous les jours libres

- [ ] **Remplacer entièrement `assets/js/availability.js` par :**

```js
(() => {
  const DEFAULT_API_URL = 'https://api.lesvendredis.casa/availability';

  const MONTHS_EN = ['January','February','March','April','May','June','July','August','September','October','November','December'];
  const MONTHS_FR = ['Janvier','Février','Mars','Avril','Mai','Juin','Juillet','Août','Septembre','Octobre','Novembre','Décembre'];
  const DAYS_EN = ['M','T','W','T','F','S','S'];
  const DAYS_FR = ['L','M','M','J','V','S','D'];

  function toIso(date) {
    const y = date.getFullYear();
    const m = String(date.getMonth() + 1).padStart(2, '0');
    const d = String(date.getDate()).padStart(2, '0');
    return `${y}-${m}-${d}`;
  }

  function buildAvailabilityMap(days) {
    const map = new Map();
    (days || []).forEach(day => {
      if (day && typeof day.date === 'string') map.set(day.date, day.available === true);
    });
    return map;
  }

  function renderMonth(year, month, availMap, lang, offset, maxOffset) {
    const months = lang === 'fr' ? MONTHS_FR : MONTHS_EN;
    const days   = lang === 'fr' ? DAYS_FR   : DAYS_EN;

    const first    = new Date(year, month, 1);
    const last     = new Date(year, month + 1, 0);
    const startDay = (first.getDay() + 6) % 7; // Mon=0
    const today    = new Date(); today.setHours(0,0,0,0);

    const prevDisabled = offset === 0 ? 'disabled' : '';
    const nextDisabled = offset === maxOffset ? 'disabled' : '';

    const arrowPrev = lang === 'fr' ? 'Mois précédent' : 'Previous month';
    const arrowNext = lang === 'fr' ? 'Mois suivant'   : 'Next month';

    let grid = '';
    days.forEach(d => { grid += `<span class="cal-dow" aria-hidden="true">${d}</span>`; });
    for (let i = 0; i < startDay; i++) grid += '<span class="cal-empty" aria-hidden="true"></span>';

    for (let d = 1; d <= last.getDate(); d++) {
      const date = new Date(year, month, d);
      const iso  = toIso(date);
      const isPast = date < today;
      const avail  = availMap.get(iso);

      let cls = 'cal-day';
      let dot = '';
      if (isPast) {
        cls += ' cal-past';
      } else if (avail === false) {
        cls += ' cal-booked';
      } else if (avail === true) {
        cls += ' cal-avail';
        dot = '<span class="cal-dot" aria-hidden="true"></span>';
      }
      grid += `<span class="${cls}">${d}${dot}</span>`;
    }

    return `
      <div class="cal-header">
        <button class="cal-arrow" data-dir="-1" aria-label="${arrowPrev}" ${prevDisabled}>‹</button>
        <div class="cal-title">
          <span class="cal-month-name">${months[month]}</span>
          <span class="cal-year">${year}</span>
        </div>
        <button class="cal-arrow" data-dir="1" aria-label="${arrowNext}" ${nextDisabled}>›</button>
      </div>
      <div class="cal-grid" role="grid">${grid}</div>`;
  }

  function init() {
    const container = document.getElementById('availability-cal');
    if (!container) return;

    const lang   = document.documentElement.lang || 'en';
    const apiUrl = container.dataset.availabilityUrl || DEFAULT_API_URL;
    const now    = new Date();

    const fromDate = new Date(now.getFullYear(), now.getMonth(), 1);
    const toDate   = new Date(now.getFullYear(), now.getMonth() + 3, 0);

    let availMap  = new Map();
    let offset    = 0;
    const maxOffset = 2;

    function render() {
      const d     = new Date(now.getFullYear(), now.getMonth() + offset, 1);
      const year  = d.getFullYear();
      const month = d.getMonth();

      const legend   = lang === 'fr' ? '• jours libres' : '• available days';
      const noteText = lang === 'fr'
        ? 'Synchronisé avec les réservations directes, Airbnb et Booking.'
        : 'Synced with direct bookings, Airbnb, and Booking.';

      container.innerHTML = `
        ${renderMonth(year, month, availMap, lang, offset, maxOffset)}
        <p class="cal-legend">${legend}</p>
        <p class="cal-note">${noteText}</p>`;

      container.querySelectorAll('.cal-arrow').forEach(btn => {
        btn.addEventListener('click', () => {
          const dir = parseInt(btn.dataset.dir, 10);
          const next = offset + dir;
          if (next < 0 || next > maxOffset) return;
          offset = next;
          render();
        });
      });
    }

    container.innerHTML = `<p class="cal-loading">${lang === 'fr' ? 'Chargement…' : 'Loading…'}</p>`;

    fetch(`${apiUrl}?from=${toIso(fromDate)}&to=${toIso(toDate)}`)
      .then(r => r.ok ? r.json() : Promise.reject())
      .then(data => { availMap = buildAvailabilityMap(data.days); render(); })
      .catch(() => { container.innerHTML = ''; });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
```

- [ ] **Commit**

```bash
git add assets/js/availability.js
git commit -m "feat: Calendar rewrite — single month, arrows, typographic states"
```

---

### Task 2 : CSS — remplacer le bloc calendrier

**Files:**
- Modify: `assets/css/main.css` (lignes 1155–1247)

- [ ] **Remplacer le bloc `/* ── availability calendar ── */` jusqu'à `.cal-swatch-booked` (inclus) par :**

```css
/* ── availability calendar ── */
.availability-cal {
  display: flex;
  flex-direction: column;
  gap: 20px;
  padding: clamp(24px, 4vw, 40px) 0;
}
.cal-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
}
.cal-title {
  display: flex;
  align-items: baseline;
  gap: 10px;
}
.cal-month-name {
  font-family: var(--serif);
  font-size: clamp(36px, 7vw, 60px);
  font-weight: 300;
  line-height: 1;
  color: var(--ink);
  letter-spacing: -.02em;
}
.cal-year {
  font-family: var(--sans);
  font-size: clamp(13px, 1.5vw, 16px);
  font-weight: 300;
  color: var(--muted);
  letter-spacing: .06em;
}
.cal-arrow {
  background: none;
  border: none;
  font-family: var(--serif);
  font-size: clamp(28px, 4vw, 40px);
  color: var(--ink);
  cursor: pointer;
  line-height: 1;
  padding: 4px 8px;
  opacity: .7;
  transition: opacity .15s;
  min-width: 44px;
  min-height: 44px;
  display: flex;
  align-items: center;
  justify-content: center;
}
.cal-arrow:hover { opacity: 1; }
.cal-arrow:disabled { opacity: .18; cursor: default; }
.cal-dow {
  font-size: 9px;
  letter-spacing: .2em;
  text-transform: uppercase;
  color: var(--muted);
  text-align: center;
  padding-bottom: 8px;
  font-weight: 500;
}
.cal-grid {
  display: grid;
  grid-template-columns: repeat(7, minmax(0, 1fr));
  gap: clamp(4px, 1.2vw, 10px);
}
.cal-day {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 4px;
  min-height: clamp(38px, 5vw, 52px);
  font-family: var(--serif);
  font-size: clamp(16px, 2.5vw, 22px);
  font-weight: 300;
  color: var(--ink);
}
.cal-empty { pointer-events: none; }
.cal-past { opacity: .22; }
.cal-booked {
  opacity: .3;
  text-decoration: line-through;
  text-decoration-color: var(--muted);
}
.cal-avail { color: var(--ink); }
.cal-dot {
  width: 4px;
  height: 4px;
  border-radius: 50%;
  background: var(--accent);
  flex-shrink: 0;
}
.cal-legend {
  font-size: 12px;
  color: var(--muted);
  letter-spacing: .04em;
}
.cal-note {
  font-size: 11px;
  color: var(--muted);
  opacity: .7;
}
.cal-loading {
  font-size: 13px;
  color: var(--muted);
  padding: clamp(20px, 4vw, 40px) 0;
}
```

- [ ] **Commit**

```bash
git add assets/css/main.css
git commit -m "feat: Calendar CSS — large typographic single-month design"
```

---

### Task 3 : CSS — refonte section "Come stay" homepage

**Files:**
- Modify: `assets/css/main.css` (bloc `.come-stay*`)

- [ ] **Remplacer le bloc `/* ── come stay (home booking) ── */` jusqu'à la fin de `.come-stay-*` par :**

Trouve la ligne qui commence `/* ── come stay (home booking) ── */` et remplace jusqu'à la prochaine section `/* ──` par :

```css
/* ── come stay (home booking) ── */
.come-stay {
  border-top: 1px solid var(--rule);
  padding: clamp(72px, 10vw, 120px) 0;
}
.come-stay-inner {
  max-width: 880px;
  display: flex;
  flex-direction: column;
  gap: clamp(40px, 6vw, 64px);
}
.come-stay-text {
  display: flex;
  flex-direction: column;
  gap: clamp(16px, 2vw, 24px);
}
.come-stay-h2 {
  font-family: var(--serif);
  font-size: clamp(40px, 7vw, 72px);
  font-weight: 300;
  line-height: .95;
  letter-spacing: -.02em;
  color: var(--ink);
}
.come-stay-lead {
  font-size: clamp(15px, 1.5vw, 18px);
  color: var(--ink-soft);
  line-height: 1.65;
  max-width: 52ch;
}
.come-stay-email {
  display: inline-block;
  font-family: var(--serif);
  font-size: clamp(18px, 2.5vw, 26px);
  font-style: italic;
  color: var(--accent);
  text-decoration: none;
  transition: opacity .15s;
}
.come-stay-email:hover { opacity: .7; }
.come-stay-alt {
  font-size: 13px;
  color: var(--muted);
  line-height: 1.6;
}
.come-stay-alt a { color: var(--muted); }
.come-stay-alt a:hover { color: var(--ink); }
.come-stay-calendar {
  border-top: 1px solid var(--rule);
  padding-top: clamp(32px, 5vw, 56px);
}
```

- [ ] **Commit**

```bash
git add assets/css/main.css
git commit -m "feat: Come-stay section CSS — vertical layout, large serif heading"
```

---

### Task 4 : HTML section homepage EN + FR

**Files:**
- Modify: `_includes/booking.html`
- Modify: `_includes/booking-fr.html`

- [ ] **Remplacer entièrement `_includes/booking.html` par :**

```html
<section class="come-stay" id="stay">
  <div class="wrap come-stay-inner">
    <div class="come-stay-text">
      <h2 class="come-stay-h2">Come stay.</h2>
      <p class="come-stay-lead">The simplest way is to write to Bolo directly. We check the dates, talk a little, and see if the place feels right.</p>
      <a class="come-stay-email" href="&#109;&#97;&#105;&#108;&#116;&#111;&#58;&#104;&#101;&#108;&#108;&#111;&#64;&#108;&#101;&#115;&#118;&#101;&#110;&#100;&#114;&#101;&#100;&#105;&#115;&#46;&#99;&#97;&#115;&#97;">Write to Bolo →</a>
      <p class="come-stay-alt">Also on <a href="https://airbnb.fr/h/lesvendredis" target="_blank" rel="noopener">Airbnb</a> and <a href="https://www.booking.com/hotel/mq/les-vendredis.html" target="_blank" rel="noopener">Booking</a> if you prefer a platform.</p>
    </div>
    <div class="come-stay-calendar">
      <div id="availability-cal" class="availability-cal" data-availability-url="https://api.lesvendredis.casa/availability" aria-live="polite"></div>
    </div>
  </div>
</section>
```

- [ ] **Remplacer entièrement `_includes/booking-fr.html` par :**

```html
<section class="come-stay" id="reserver">
  <div class="wrap come-stay-inner">
    <div class="come-stay-text">
      <h2 class="come-stay-h2">Venir dormir.</h2>
      <p class="come-stay-lead">La façon la plus simple, c'est d'écrire à Bolo directement. On regarde les dates ensemble, on discute un peu, et on voit si le lieu vous convient.</p>
      <a class="come-stay-email" href="&#109;&#97;&#105;&#108;&#116;&#111;&#58;&#104;&#101;&#108;&#108;&#111;&#64;&#108;&#101;&#115;&#118;&#101;&#110;&#100;&#114;&#101;&#100;&#105;&#115;&#46;&#99;&#97;&#115;&#97;">Écrire à Bolo →</a>
      <p class="come-stay-alt">Également sur <a href="https://airbnb.fr/h/lesvendredis" target="_blank" rel="noopener">Airbnb</a> et <a href="https://www.booking.com/hotel/mq/les-vendredis.html" target="_blank" rel="noopener">Booking</a> si vous préférez une plateforme.</p>
    </div>
    <div class="come-stay-calendar">
      <div id="availability-cal" class="availability-cal" data-availability-url="https://api.lesvendredis.casa/availability" aria-live="polite"></div>
    </div>
  </div>
</section>
```

- [ ] **Commit**

```bash
git add _includes/booking.html _includes/booking-fr.html
git commit -m "feat: Booking section HTML — vertical layout, single calendar"
```

---

### Task 5 : Page manifesto `/come-stay/` — repositionner le calendrier

**Files:**
- Modify: `come-stay.html`
- Modify: `fr/venir-dormir.html`

L'objectif : le calendrier est intégré **avant** le CTA final (section `.manifesto-close`), comme moment fort. Il ne doit pas y avoir deux `#availability-cal` dans la même page — la homepage et la page come-stay sont des pages distinctes, donc pas de conflit.

- [ ] **Dans `come-stay.html`, remplacer la section `.manifesto-close` par :**

```html
  <section class="manifesto-availability">
    <div class="wrap">
      <div id="availability-cal" class="availability-cal" data-availability-url="https://api.lesvendredis.casa/availability" aria-live="polite"></div>
    </div>
  </section>

  <section class="manifesto-close">
    <div class="wrap">
      <div class="manifesto-close-left">
        <p>Write to me &mdash; we&rsquo;ll check the dates, I&rsquo;ll answer your questions, and we&rsquo;ll simply see if it fits.</p>
        <p class="manifesto-email">
          <a href="#" data-email-link data-ep-u="olleh" data-ep-d="asac.siderdnevsel">Write to Bolo →</a><br>
          <span data-email-text data-ep-u="olleh" data-ep-d="asac.siderdnevsel">hello [at] lesvendredis [dot] casa</span>
        </p>
        <p><a href="https://wa.me/33666535289?text=Hi%20!%20I%27d%20love%20to%20come%20to%20Les%20Vendredis%20%E2%80%94%20could%20we%20chat%20about%20a%20stay%20?" target="_blank" rel="noopener">WhatsApp →</a></p>
      </div>
      <div class="manifesto-close-right">
        <ul class="manifesto-facts">
          <li>From 150 €/night, direct.</li>
          <li>One night possible depending on dates. Two nights to really slow down.</li>
          <li>2 adults · 1 child · pets welcome.</li>
          <li>600 m² private garden.</li>
          <li>Also on <a href="https://airbnb.fr/h/lesvendredis" target="_blank" rel="noopener">Airbnb</a> and <a href="https://www.booking.com/Share-ch4vXj" target="_blank" rel="noopener">Booking</a>, if you prefer to use a platform.</li>
          <li>Or ask your AI assistant to book via <a href="/.well-known/agent.json">X402 →</a></li>
        </ul>
      </div>
    </div>
  </section>
```

- [ ] **Dans `fr/venir-dormir.html`, faire la même restructuration** (section `.manifesto-availability` avec le `#availability-cal` avant `.manifesto-close`). Le texte FR de la section close reste identique au contenu FR actuel du fichier.

- [ ] **Ajouter le CSS de la section availability dans `main.css`** (après le bloc `.availability-cal`) :

```css
/* ── manifesto availability section ── */
.manifesto-availability {
  border-top: 1px solid var(--rule);
  padding: clamp(56px, 8vw, 96px) 0;
}
.manifesto-availability .wrap {
  max-width: 880px;
}
```

- [ ] **Commit**

```bash
git add come-stay.html fr/venir-dormir.html assets/css/main.css
git commit -m "feat: Manifesto pages — calendar as centrepiece before CTA"
```

---

### Task 6 : Build + tests

- [ ] **Build Jekyll localement**

```bash
bundle exec jekyll build
```
Expected : pas d'erreur.

- [ ] **Lancer les tests**

```bash
bundle exec rake test
```
Expected : tous les liens et images valides.

- [ ] **Push final**

```bash
git push origin main
```
