# Design — llm.txt par page pour agents autonomes

Date: 2026-05-22
Statut: validé

## Contexte

Les Vendredis dispose d'un backend X402 (Hono, Polygon) permettant à des agents autonomes de réserver la cabane directement via paiement HTTP natif. Pour que ces agents puissent découvrir le lieu et interagir avec l'API, chaque page du site doit exposer un fichier `llm.txt` lisible par un LLM.

## Objectif

Générer automatiquement un `llm.txt` côte à côte avec chaque page HTML du site Jekyll, contenant :
- Le contenu utile de la page (texte structuré, sans HTML)
- Les métadonnées du lieu (prix, règles, capacité)
- La description complète des endpoints de réservation X402 (sur les pages séjour)

## Architecture

### Approche retenue : plugin Jekyll (`_plugins/llm_generator.rb`)

Un générateur Jekyll itère sur toutes les pages et posts et produit un fichier `llm.txt` dans `_site/`. Aucune modification des fichiers existants — le plugin lit le front matter déjà en place.

### Fichiers générés

| URL | Source |
|-----|--------|
| `lesvendredis.casa/llm.txt` | Global — résumé du lieu + liste de toutes les URLs + lien agent.json |
| `lesvendredis.casa/come-stay/llm.txt` | Page séjour EN — avec endpoints complets |
| `lesvendredis.casa/fr/venir-dormir/llm.txt` | Page séjour FR — avec endpoints complets |
| `lesvendredis.casa/hebergement-insolite-sainte-luce/llm.txt` | Page SEO — avec endpoints |
| `lesvendredis.casa/unique-stay-martinique/llm.txt` | Page SEO EN — avec endpoints |
| `lesvendredis.casa/unique-stay-pet-friendly-martinique/llm.txt` | Page SEO EN — avec endpoints |
| `lesvendredis.casa/fr/hebergement-atypique-martinique/llm.txt` | Page SEO FR — avec endpoints |
| `lesvendredis.casa/fr/hebergement-atypique-animal-accepte-martinique/llm.txt` | Page SEO FR — avec endpoints |
| `lesvendredis.casa/roches-gravees-sainte-luce/llm.txt` | Page découverte — sans endpoints |
| `lesvendredis.casa/trails-sainte-luce/llm.txt` | Page découverte — sans endpoints |
| `lesvendredis.casa/montravail-forest/llm.txt` | Page découverte — sans endpoints |
| `lesvendredis.casa/journal/:slug/llm.txt` | Posts journal — contenu narratif + lien agent.json |

### Format du llm.txt (pages séjour)

```
# Les Vendredis — A-frame artisanale, Sainte-Luce, Martinique
URL: https://lesvendredis.casa/come-stay/
Lang: en

## About this page
[description ou summary du front matter]

## The stay
Price: 80 EURC / night (Polygon mainnet)
Max guests: 3
Min nights: 1 — Max nights: 21
Advance booking: 21 days minimum
Preparation days between bookings: 2
Features: air conditioning, private garden, pet-friendly

## Book via autonomous agent (x402)

Agent metadata: GET https://api.lesvendredis.casa/.well-known/agent.json

GET /rules
  Returns: minNights, maxNights, minAdvanceDays, maxGuests, preparationDays, price

GET /availability?from=YYYY-MM-DD&to=YYYY-MM-DD
  Returns: list of days with available: true/false, price, currency, rules

POST /quote
  Body: { "date": "YYYY-MM-DD", "nights": 2, "guests": 2 }
  Returns: totalPrice, checkOut, currency, network, asset, payTo, expiresAt

POST /book  [x402 payment required — EURC on Polygon mainnet]
  Body: { "date": "YYYY-MM-DD", "nights": 2, "guests": 2 }
  Payment: exact scheme, 80 EURC per night × nights
  Returns: bookingId, date, checkOut, guests, nights, price, network

GET /booking/:id
  Returns: booking status and details

POST /booking/:id/cancel
  Returns: { cancelled: true, bookingId }

GET /calendar.ics
  Returns: iCal export of all confirmed bookings
```

### Format du llm.txt (pages journal et découverte)

```
# [title]
URL: https://lesvendredis.casa/journal/:slug/
Lang: [lang]

## Content
[description ou excerpt du post]

## Book the A-frame
Agent metadata: GET https://api.lesvendredis.casa/.well-known/agent.json
```

### llm.txt global (racine)

```
# Les Vendredis
URL: https://lesvendredis.casa/
Description: Handmade A-frame cabin with private garden in Sainte-Luce, Martinique.
Price: 80 EURC / night — Max 3 guests

## Pages
[liste de toutes les URLs du site avec leur titre]

## Booking API
Agent metadata: GET https://api.lesvendredis.casa/.well-known/agent.json
```

## Détection des pages "séjour"

Le plugin détecte une page séjour via le front matter :
```yaml
llm_booking: true
```

À ajouter sur les pages come-stay, venir-dormir, et les pages SEO hébergement.

## robots.txt

Ajouter une ligne pour pointer vers le llm.txt global :
```
LLM: https://lesvendredis.casa/llm.txt
```

## Implémentation

1. `_plugins/llm_generator.rb` — générateur Jekyll
2. Ajout de `llm_booking: true` dans le front matter des pages séjour
3. `llm.txt` global à la racine (page Jekyll standard)
4. Mise à jour de `robots.txt`
