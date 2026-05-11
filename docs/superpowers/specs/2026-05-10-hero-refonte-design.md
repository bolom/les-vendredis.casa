# Refonte narrative du site lesvendredis.casa

**Date :** 2026-05-10
**Périmètre :** Hero (EN + FR), bande creds (EN + FR), ordre des sections homepage

---

## Contexte

Le site actuel parle le langage d'une fiche de location — hero descriptif, bande de specs produit, galerie avant le journal. L'identité réelle des Vendredis est différente : une famille de quatre (Anaïs, Bolo, Léon, Samsam) qui construit une cabane A-frame à Sainte-Luce depuis 2022, sur un terrain hérité, et qui y retourne chaque weekend. Le journal documente ça en temps réel. Le visiteur qui arrive sur le site doit comprendre ça avant de penser à réserver.

---

## Ce qui change

### 1. Ordre des sections — homepage

**Avant :** Hero → Journal → Galerie → FAQ → Booking

**Après :** Hero → Journal → Galerie → FAQ → Booking

L'ordre reste le même, mais le journal remonte visuellement en importance grâce au hero reformulé qui l'annonce. Pas de restructuration technique des includes.

> Décision : on ne déplace pas les sections physiquement — le journal est déjà en position 2, ce qui est correct. Ce qui change c'est que le hero crée une attente qui appelle le journal, pas la galerie.

---

### 2. Hero — texte FR

**Eyebrow (inchangé) :**
> Maison d'hôtes · Sainte-Luce, Martinique

**H1 (remplace "Cabane A-frame en Martinique.") :**
> Notre vendredi
> en *Martinique.*

**Lead 1 (remplace la description technique) :**
> Anaïs, Bolo, Léon et Samsam. On construit cette cabane A-frame depuis 2022 — chaque weekend, chaque jour férié, chaque fois qu'on peut. C'est notre vendredi.

**Lead 2 (remplace "Une location de vacances tranquille...") :**
> *Quand on n'y est pas, vous pouvez y être.*

---

### 3. Hero — texte EN

**Eyebrow (inchangé) :**
> Guesthouse · Sainte-Luce, Martinique

**H1 (remplace "A-frame cabin in Martinique.") :**
> Our Friday
> in *Martinique.*

**Lead 1 :**
> Anaïs, Bolo, Léon and Samsam. We've been building this A-frame cabin since 2022 — every weekend, every holiday, whenever we can. This is our Friday.

**Lead 2 :**
> *When we're not there, you can be.*

---

### 4. Bande creds — FR

Remplace les quatre cases actuelles (Lieu / Construit / Capacité / Animaux) par :

| Label | Valeur |
|---|---|
| DEPUIS | *2022 — en cours* |
| OÙ | *Sainte-Luce, dans les hauteurs* |
| POUR | *2 adultes & 1 enfant* |
| ANIMAUX | *Bienvenus — Samsam le premier* |

---

### 5. Bande creds — EN

| Label | Valeur |
|---|---|
| SINCE | *2022 — ongoing* |
| WHERE | *Sainte-Luce, in the hills* |
| FOR | *2 adults & 1 child* |
| PETS | *Welcome — Samsam was first* |

---

## Ce qui ne change pas

- Design graphique, typographie, palette de couleurs — rien ne change
- Structure HTML des sections — aucune section déplacée
- La galerie, la FAQ, la section booking — textes et contenu inchangés
- Le journal — les articles existants ne bougent pas

---

## Fichiers à modifier

- `_includes/hero.html` — textes EN
- `_includes/hero-fr.html` — textes FR

C'est tout. Deux fichiers, modifications textuelles uniquement.

---

## Critères de succès

- Le premier paragraphe dit qui vous êtes, pas ce que vous louez
- "2022 — en cours" remplace "2022—2024" (le chantier continue)
- "Samsam le premier / Samsam was first" — la case animaux a une voix
- Les textes EN et FR sont cohérents en ton et en sens
