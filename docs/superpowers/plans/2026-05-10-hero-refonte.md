# Hero Refonte — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reformuler les textes du hero et de la bande creds EN et FR pour refléter l'identité réelle des Vendredis — une famille qui construit son lieu depuis 2022 et l'ouvre aux visiteurs.

**Architecture:** Modifications textuelles uniquement dans deux fichiers Jekyll includes. Aucun changement de structure HTML, CSS, ou logique. Les variables Liquid (lang, url, etc.) restent intactes.

**Tech Stack:** Jekyll 4.3, HTML, Liquid templates

---

### Task 1 : Hero EN — reformuler le texte

**Files:**
- Modify: `_includes/hero.html`

- [ ] **Step 1 : Ouvrir le fichier et repérer les lignes à changer**

Le fichier actuel contient ces lignes à modifier (lignes 9–12) :

```html
<div class="eyebrow">Guesthouse · Sainte-Luce, Martinique</div>
<h1>A-frame cabin<br>in <em>Martinique.</em></h1>
<p class="lead">A handmade A-frame cabin and a private garden in the hills of Sainte-Luce, southern Martinique.</p>
<p class="lead">A quiet vacation rental for couples, families, and friends — pets welcome.</p>
```

- [ ] **Step 2 : Remplacer le h1 et les deux leads**

Remplacer exactement ces 4 lignes par :

```html
<div class="eyebrow">Guesthouse · Sainte-Luce, Martinique</div>
<h1>Our Friday<br>in <em>Martinique.</em></h1>
<p class="lead">Anaïs, Bolo, Léon and Samsam. We've been building this A-frame cabin since 2022 — every weekend, every holiday, whenever we can. This is our Friday.</p>
<p class="lead">When we're not there, you can be.</p>
```

- [ ] **Step 3 : Vérifier visuellement**

Lancer le serveur Jekyll local :
```bash
bundle exec jekyll serve
```
Ouvrir `http://localhost:4000` et vérifier :
- H1 affiche "Our Friday / in *Martinique.*"
- Lead 1 cite Anaïs, Bolo, Léon and Samsam
- Lead 2 affiche "When we're not there, you can be." en italique

- [ ] **Step 4 : Commit**

```bash
git add _includes/hero.html
git commit -m "feat: reformuler hero EN — notre vendredi, pas une fiche produit"
```

---

### Task 2 : Hero FR — reformuler le texte

**Files:**
- Modify: `_includes/hero-fr.html`

- [ ] **Step 1 : Repérer les lignes à changer**

Le fichier actuel contient ces lignes (lignes 9–12) :

```html
<div class="eyebrow">Maison d'hôtes · Sainte-Luce, Martinique</div>
<h1>Cabane A-frame<br>en <em>Martinique.</em></h1>
<p class="lead">Une cabane A-frame artisanale et un jardin privé dans les hauteurs de Sainte-Luce, au sud de la Martinique.</p>
<p class="lead">Une location de vacances tranquille pour couples, familles et amis — animaux bienvenus.</p>
```

- [ ] **Step 2 : Remplacer le h1 et les deux leads**

```html
<div class="eyebrow">Maison d'hôtes · Sainte-Luce, Martinique</div>
<h1>Notre vendredi<br>en <em>Martinique.</em></h1>
<p class="lead">Anaïs, Bolo, Léon et Samsam. On construit cette cabane A-frame depuis 2022 — chaque weekend, chaque jour férié, chaque fois qu'on peut. C'est notre vendredi.</p>
<p class="lead">Quand on n'y est pas, vous pouvez y être.</p>
```

- [ ] **Step 3 : Vérifier visuellement**

Ouvrir `http://localhost:4000/fr/` et vérifier :
- H1 affiche "Notre vendredi / en *Martinique.*"
- Lead 1 cite Anaïs, Bolo, Léon et Samsam avec la bonne ponctuation française
- Lead 2 affiche "Quand on n'y est pas, vous pouvez y être." en italique

- [ ] **Step 4 : Commit**

```bash
git add _includes/hero-fr.html
git commit -m "feat: reformuler hero FR — notre vendredi, pas une fiche produit"
```

---

### Task 3 : Creds EN — reformuler les quatre cases

**Files:**
- Modify: `_includes/hero.html`

- [ ] **Step 1 : Repérer le bloc creds dans hero.html**

Le bloc actuel (lignes 19–24) :

```html
<div class="creds">
  <div class="cred"><span class="k">Location</span><span class="v">Sainte-Luce</span></div>
  <div class="cred"><span class="k">Built</span><span class="v">By hand · 2022—2024</span></div>
  <div class="cred"><span class="k">Sleeps</span><span class="v">Two adults &amp; one child</span></div>
  <div class="cred"><span class="k">Pets</span><span class="v"><img src="{{ '/public/images/pet-friendly-logo.png' | relative_url }}" alt="Pet friendly" class="cred-pet-logo" /></span></div>
</div>
```

- [ ] **Step 2 : Remplacer par les nouvelles valeurs**

```html
<div class="creds">
  <div class="cred"><span class="k">Since</span><span class="v">2022 — ongoing</span></div>
  <div class="cred"><span class="k">Where</span><span class="v">Sainte-Luce, in the hills</span></div>
  <div class="cred"><span class="k">For</span><span class="v">2 adults &amp; 1 child</span></div>
  <div class="cred"><span class="k">Pets</span><span class="v">Welcome — Samsam was first</span></div>
</div>
```

Note : on retire le logo pet-friendly de la bande creds (il reste dans le footer). La case Pets reçoit maintenant du texte avec la voix du lieu.

- [ ] **Step 3 : Vérifier visuellement**

Ouvrir `http://localhost:4000` et vérifier :
- 4 cases présentes sous le hero
- "2022 — ongoing" (pas 2022—2024)
- "Samsam was first" visible dans la case Pets
- Pas de logo cassé (le logo a été retiré de cette section)

- [ ] **Step 4 : Commit**

```bash
git add _includes/hero.html
git commit -m "feat: reformuler creds EN — voix humaine, chantier en cours"
```

---

### Task 4 : Creds FR — reformuler les quatre cases

**Files:**
- Modify: `_includes/hero-fr.html`

- [ ] **Step 1 : Repérer le bloc creds dans hero-fr.html**

Le bloc actuel :

```html
<div class="creds">
  <div class="cred"><span class="k">Lieu</span><span class="v">Sainte-Luce</span></div>
  <div class="cred"><span class="k">Construit</span><span class="v">À la main · 2022—2024</span></div>
  <div class="cred"><span class="k">Capacité</span><span class="v">Deux adultes &amp; un enfant</span></div>
  <div class="cred"><span class="k">Animaux</span><span class="v"><img src="{{ '/public/images/pet-friendly-logo.png' | relative_url }}" alt="Pet friendly" class="cred-pet-logo" /></span></div>
</div>
```

- [ ] **Step 2 : Remplacer par les nouvelles valeurs**

```html
<div class="creds">
  <div class="cred"><span class="k">Depuis</span><span class="v">2022 — en cours</span></div>
  <div class="cred"><span class="k">Où</span><span class="v">Sainte-Luce, dans les hauteurs</span></div>
  <div class="cred"><span class="k">Pour</span><span class="v">2 adultes &amp; 1 enfant</span></div>
  <div class="cred"><span class="k">Animaux</span><span class="v">Bienvenus — Samsam le premier</span></div>
</div>
```

- [ ] **Step 3 : Vérifier visuellement**

Ouvrir `http://localhost:4000/fr/` et vérifier :
- "2022 — en cours" (pas 2022—2024)
- "Samsam le premier" dans la case Animaux
- Pas de logo cassé

- [ ] **Step 4 : Commit**

```bash
git add _includes/hero-fr.html
git commit -m "feat: reformuler creds FR — voix humaine, chantier en cours"
```

---

### Task 5 : Vérification finale et push

**Files:** aucun nouveau fichier

- [ ] **Step 1 : Vérifier les deux langues côte à côte**

- `http://localhost:4000` — version EN
- `http://localhost:4000/fr/` — version FR

Checklist :
- [ ] H1 EN : "Our Friday / in *Martinique.*"
- [ ] H1 FR : "Notre vendredi / en *Martinique.*"
- [ ] Lead EN cite "Anaïs, Bolo, Léon and Samsam"
- [ ] Lead FR cite "Anaïs, Bolo, Léon et Samsam"
- [ ] Dernière ligne EN en italique : "When we're not there, you can be."
- [ ] Dernière ligne FR en italique : "Quand on n'y est pas, vous pouvez y être."
- [ ] Creds EN : Since / Where / For / Pets avec "Samsam was first"
- [ ] Creds FR : Depuis / Où / Pour / Animaux avec "Samsam le premier"
- [ ] Boutons de réservation toujours présents et fonctionnels

- [ ] **Step 2 : Push et vérifier le déploiement**

```bash
git push origin main
```

Attendre ~2 minutes puis vérifier sur `https://lesvendredis.casa` et `https://lesvendredis.casa/fr/`.
