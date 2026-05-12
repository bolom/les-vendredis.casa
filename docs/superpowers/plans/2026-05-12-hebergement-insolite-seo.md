# Hebergement Insolite SEO Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Retarget the existing French cabin landing page for `hebergement insolite en Martinique` without changing its URL.

**Architecture:** This is a static Jekyll content and metadata change. The landing page frontmatter and visible sections provide the primary search signal, the French homepage FAQ provides internal linking, and the landing-page FAQ JSON-LD mirrors the visible questions for structured data.

**Tech Stack:** Jekyll, Liquid includes, static HTML, JSON-LD.

---

## File Structure

- Modify `fr/hebergement-atypique-martinique.html`: primary landing page copy, frontmatter metadata, hero, intent-answer section, visible FAQ content.
- Modify `_includes/faq-fr.html`: homepage French FAQ internal link anchor to the landing page.
- Modify `_includes/schema-faq-landing.html`: French FAQPage JSON-LD questions and answers for the landing page.
- Do not modify `_includes/schema-lodging.html`: it already reads `page.description`.

---

### Task 1: Retarget Landing Page Metadata And Hero

**Files:**
- Modify: `fr/hebergement-atypique-martinique.html`

- [ ] **Step 1: Update frontmatter metadata**

Replace the existing `title`, `seo_title`, and `description` values with:

```yaml
title: "Hebergement insolite en Martinique"
seo_title: "Hebergement insolite Martinique - Cabane A-frame a Sainte-Luce | Les Vendredis"
description: "Hebergement insolite en Martinique : cabane A-frame construite a la main a Sainte-Luce, jardin tropical privatif, animaux acceptes, douche exterieure et calme sans clim ni television."
```

Keep `canonical_url` and `permalink` unchanged.

- [ ] **Step 2: Update hero search signal**

In the hero, replace:

```html
<div class="eyebrow">Hébergement atypique · Sainte-Luce, Martinique</div>
<h1>Cabane A-frame, hébergement atypique<br>en <em>Martinique.</em></h1>
<p class="lead">Une cabane A-frame de 18m² construite à la main, à Sainte-Luce, dans les hauteurs du sud de la Martinique.</p>
<p class="lead">Pour deux adultes, un enfant, et leur animal — animaux bienvenus, c'est important pour nous.</p>
```

with:

```html
<div class="eyebrow">Hébergement insolite · Sainte-Luce, Martinique</div>
<h1>Hébergement insolite<br>en <em>Martinique.</em></h1>
<p class="lead">Une cabane A-frame de 18m² construite à la main, à Sainte-Luce, dans les hauteurs du sud de la Martinique.</p>
<p class="lead">Un hébergement atypique pour deux adultes, un enfant, et leur animal — jardin tropical privatif, douche extérieure, pas de clim, pas de télé.</p>
```

- [ ] **Step 3: Verify the page still has one H1**

Run:

```bash
rg -n "<h1|</h1>" fr/hebergement-atypique-martinique.html
```

Expected: only one opening `<h1>` and one closing `</h1>`.

---

### Task 2: Add Search Intent Section To Landing Page

**Files:**
- Modify: `fr/hebergement-atypique-martinique.html`

- [ ] **Step 1: Insert the intent-answer section**

After the closing `</div>` of the `.creds` block and before the next `<div class="wrap">`, insert:

```html
<div class="wrap">
  <section class="faq-section">
    <div class="section-head">
      <h2>Pourquoi choisir cet hébergement insolite <em>en Martinique ?</em></h2>
      <p class="sub">Une cabane simple, un jardin vivant, et le sud de l'île à portée de route.</p>
    </div>
    <div class="faq-list">
      <div class="faq-item"><h3>Une vraie cabane A-frame</h3><p>La cabane a été construite à la main, en bois, sur le terrain familial. Ce n'est pas une chambre standard déguisée en décor nature : lit en mezzanine sous le pignon, cuisine équipée dans le préau, douche extérieure dans le jardin, eau chaude depuis mai 2026.</p></div>
      <div class="faq-item"><h3>Un jardin tropical privatif</h3><p>600m² pour vous, dessinés et plantés par Anaïs : manguiers, goyaviers, bougainvilliers, fruits de la passion, rochers et allées plantées. Quand les fruits tombent pendant votre séjour, ils sont pour vous.</p></div>
      <div class="faq-item"><h3>Sainte-Luce, côté nature</h3><p>Vous êtes dans les hauteurs du sud de la Martinique, à quelques minutes des plages de Sainte-Luce et tout près des Roches Gravées de Montravail. On dort au calme, puis on rejoint la côte en voiture.</p></div>
      <div class="faq-item"><h3>Pas un lodge spa</h3><p>Pas de piscine, pas de jacuzzi, pas de clim, pas de télé, pas de wifi. Les Vendredis est un hébergement insolite pour ralentir, lire dans le hamac, cuisiner dehors et vivre le jardin avec votre animal.</p></div>
    </div>
  </section>
</div>
```

- [ ] **Step 2: Verify required phrases are present**

Run:

```bash
rg -n "hébergement insolite|hébergement atypique|Sainte-Luce|jardin tropical|douche extérieure|animaux|piscine|jacuzzi|clim|wifi" fr/hebergement-atypique-martinique.html
```

Expected: all target concepts appear in natural French copy.

---

### Task 3: Refresh Landing Page Visible FAQ

**Files:**
- Modify: `fr/hebergement-atypique-martinique.html`

- [ ] **Step 1: Replace the first FAQ section content**

In the section headed `Ce que c'est vraiment.`, replace the four `.faq-item` entries with:

```html
      <div class="faq-item"><h3>Est-ce un hébergement insolite en Martinique ?</h3><p>Oui. Les Vendredis est une cabane A-frame en bois, construite à la main à Sainte-Luce, avec lit en mezzanine, cuisine extérieure, douche dans le jardin et 600m² privatifs. C'est aussi un hébergement atypique : simple, ouvert, sans télé, sans clim et sans serrures.</p></div>
      <div class="faq-item"><h3>Où se trouve la cabane ?</h3><p>À Sainte-Luce, sur la côte sud, dans les hauteurs et à quelques minutes des plages en voiture. Les Roches Gravées de Montravail sont à deux pas — l'un des trois sites d'art rupestre précolombien connus en Martinique.</p></div>
      <div class="faq-item"><h3>Pour combien de personnes ?</h3><p>La cabane accueille deux adultes, un enfant, et leur animal. Le stationnement se fait sur place, devant le terrain.</p></div>
      <div class="faq-item"><h3>Les animaux sont-ils acceptés ?</h3><p>Oui. Les Vendredis est pet friendly, vraiment. Le jardin privatif laisse de la place pour se promener, sentir, regarder, dormir à l'ombre et vivre le séjour avec vous.</p></div>
```

- [ ] **Step 2: Replace the second FAQ section content**

In the section headed `Ce qu'on ne fait pas.`, replace the four `.faq-item` entries with:

```html
      <div class="faq-item"><h3>Y a-t-il piscine, jacuzzi, clim ou wifi ?</h3><p>Non. Pas de piscine, pas de jacuzzi, pas de clim, pas de télé, pas de wifi. Si vous cherchez un lodge spa, ce n'est pas la bonne adresse. Si vous cherchez un hébergement insolite en Martinique pour ralentir dans un jardin tropical, oui.</p></div>
      <div class="faq-item"><h3>La cabane se ferme-t-elle à clé ?</h3><p>Non. La cabane n'a aucune fermeture, aucun meuble avec clé, aucun coffre. Personne n'est jamais venu jusqu'ici pour voler quoi que ce soit. On préfère que ça reste comme ça.</p></div>
      <div class="faq-item"><h3>Y a-t-il du personnel sur place ?</h3><p>Non. Pas d'accueil 24/7, pas de service en chambre. On vous montre les lieux à l'arrivée et on vous laisse vivre.</p></div>
      <div class="faq-item"><h3>Comment réserver ?</h3><p>Vous pouvez réserver sur Airbnb ou nous écrire directement par WhatsApp pour vérifier une date, poser une question ou préparer un séjour avec votre animal.</p></div>
```

- [ ] **Step 3: Verify visible FAQ questions**

Run:

```bash
rg -n "<h3>" fr/hebergement-atypique-martinique.html
```

Expected: visible questions include `Est-ce un hébergement insolite en Martinique ?`, `Où se trouve la cabane ?`, `Y a-t-il piscine, jacuzzi, clim ou wifi ?`, `Les animaux sont-ils acceptés ?`, `Pour combien de personnes ?`, and `Comment réserver ?`.

---

### Task 4: Update Homepage Internal Link Anchor

**Files:**
- Modify: `_includes/faq-fr.html`

- [ ] **Step 1: Rewrite the first homepage FAQ item**

Replace the first `.faq-item` in `_includes/faq-fr.html` with:

```html
      <div class="faq-item"><h3>Est-ce un hébergement insolite en Martinique ?</h3><p>Oui : une cabane A-frame construite à la main pendant trois ans, sans télé, sans clim, sans serrures, avec une douche extérieure dans un jardin tropical privatif. <a href="{{ '/fr/hebergement-atypique-martinique/' | relative_url }}">Voir l'hébergement insolite →</a></p></div>
```

- [ ] **Step 2: Verify the internal link target is unchanged**

Run:

```bash
rg -n "hebergement-atypique-martinique|hébergement insolite" _includes/faq-fr.html
```

Expected: the link still points to `/fr/hebergement-atypique-martinique/`, and the anchor text includes `hébergement insolite`.

---

### Task 5: Update Landing Page FAQ Schema

**Files:**
- Modify: `_includes/schema-faq-landing.html`

- [ ] **Step 1: Replace the French `mainEntity` array**

Inside `{% if page.lang == 'fr' %}`, replace the existing `mainEntity` array with:

```json
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Est-ce un hébergement insolite en Martinique ?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Oui. Les Vendredis est une cabane A-frame en bois, construite à la main à Sainte-Luce, avec lit en mezzanine, cuisine extérieure, douche dans le jardin et 600m² privatifs. C'est aussi un hébergement atypique : simple, ouvert, sans télé, sans clim et sans serrures."
      }
    },
    {
      "@type": "Question",
      "name": "Où se trouve la cabane ?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "À Sainte-Luce, sur la côte sud de la Martinique, dans les hauteurs et à quelques minutes des plages en voiture. Les Roches Gravées de Montravail sont à deux pas."
      }
    },
    {
      "@type": "Question",
      "name": "Y a-t-il piscine, jacuzzi, clim ou wifi ?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Non. Pas de piscine, pas de jacuzzi, pas de clim, pas de télé, pas de wifi. Les Vendredis est un hébergement insolite pour ralentir dans un jardin tropical, pas un lodge spa."
      }
    },
    {
      "@type": "Question",
      "name": "Les animaux sont-ils acceptés ?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Oui. Les Vendredis est pet friendly. Le jardin privatif laisse de la place pour vivre le séjour avec votre animal."
      }
    },
    {
      "@type": "Question",
      "name": "Pour combien de personnes ?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "La cabane accueille deux adultes, un enfant, et leur animal. Le stationnement se fait sur place."
      }
    },
    {
      "@type": "Question",
      "name": "Comment réserver ?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Vous pouvez réserver sur Airbnb ou écrire directement aux Vendredis par WhatsApp pour vérifier une date, poser une question ou préparer un séjour avec votre animal."
      }
    }
  ]
```

Do not change the English `{% else %}` block.

- [ ] **Step 2: Validate JSON-LD after build**

Run:

```bash
bundle exec jekyll build
```

Expected: build exits with code 0.

---

### Task 6: Build Verification And Commit

**Files:**
- Verify generated output in `_site/fr/hebergement-atypique-martinique/index.html`
- Commit modified source files and this plan

- [ ] **Step 1: Build the site**

Run:

```bash
bundle exec jekyll build
```

Expected: `done` and exit code 0.

- [ ] **Step 2: Verify generated metadata and copy**

Run:

```bash
rg -n "Hebergement insolite|Hébergement insolite|hébergement insolite|canonical|LodgingBusiness|FAQPage|jacuzzi|wifi" _site/fr/hebergement-atypique-martinique/index.html
```

Expected: generated HTML includes the new title/meta intent, unchanged canonical URL, `LodgingBusiness`, `FAQPage`, and visible copy mentioning key exclusions.

- [ ] **Step 3: Review source diff**

Run:

```bash
git diff -- fr/hebergement-atypique-martinique.html _includes/faq-fr.html _includes/schema-faq-landing.html docs/superpowers/plans/2026-05-12-hebergement-insolite-seo.md
```

Expected: diff only contains the planned SEO copy, FAQ, schema, and plan document.

- [ ] **Step 4: Commit scoped files**

Run:

```bash
git add fr/hebergement-atypique-martinique.html _includes/faq-fr.html _includes/schema-faq-landing.html docs/superpowers/plans/2026-05-12-hebergement-insolite-seo.md
git commit -m "seo: target hebergement insolite martinique"
```

Expected: commit succeeds. Existing unrelated modified files remain unstaged.
