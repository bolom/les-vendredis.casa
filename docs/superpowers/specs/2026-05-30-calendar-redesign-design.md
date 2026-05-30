# Redesign calendrier + pages "Come stay" — Les Vendredis

**Date:** 2026-05-30
**Status:** approved
**Goal:** Repenser audacieusement le calendrier de disponibilité (pièce maîtresse) et les deux pages de réservation, dans la voix éditoriale du site.

## Contexte

- Site Jekyll statique, design system éditorial : `--cream` fond, `--ink` texte, `--accent` terracotta, `--serif`, `--sans`.
- Le calendrier (`assets/js/availability.js`) appelle `https://api.lesvendredis.casa/availability` et reçoit `{days: [{date, available}]}`.
- Aujourd'hui : 3 mois côte à côte, cases colorées (vert/terracotta), grille dense.
- Pages concernées :
  - Section homepage "Come stay" : `_includes/booking.html` (EN) + `_includes/booking-fr.html` (FR)
  - Page manifesto `/come-stay/` : `come-stay.html` (EN) + `fr/venir-dormir.html` (FR)

## Direction retenue

### Calendrier — un seul grand mois, typographique

- **Un mois affiché à la fois**, centré, très aéré.
- **Nom du mois en serif géant** (`clamp(40px, 7vw, 64px)`), année en plus petit à côté.
- **Navigation par flèches** ‹ › de part et d'autre du titre. Bornes : mois courant → +2 mois (pas de navigation dans le passé, ni au-delà de la fenêtre API de 3 mois).
- **Grille 7 colonnes** aérée, gros chiffres légers (`--serif` ou `--sans` light).
- États des jours (expression **typographique**, pas de cases pleines) :
  - **Passé** : opacité ~.25, non interactif.
  - **Réservé** : chiffre estompé/barré, presque effacé.
  - **Libre** : chiffre net + **point terracotta** (`--accent`) centré dessous. Les jours libres ressortent.
- **Légende discrète** : une ligne texte, ex. `• jours libres` (FR) / `• available` (EN). Pas de swatches colorés.
- **Note de sync** conservée : "Calendrier synchronisé avec les réservations directes, Airbnb et Booking." / "Calendar synced with direct bookings, Airbnb, and Booking."

### Section homepage "Come stay"

- Casser le côte-à-côte rigide actuel. Le calendrier devient un objet posé, central ; le texte "Write to Bolo" l'accompagne sans le concurrencer.
- Plus de respiration verticale, hiérarchie typographique affirmée.
- Garder les liens : email Bolo, Airbnb, Booking.

### Page `/come-stay/` (manifesto)

- Garder la force du manifesto ("Our home is open when we're not there").
- Resserrer le rythme entre sections (transitions, espacements).
- Intégrer le calendrier comme **moment fort vers la fin**, avant le CTA final — pas un ajout en bas de page.

## Contraintes

- **Bilingue EN/FR** : labels déjà gérés via `document.documentElement.lang` dans le JS. Étendre pour les nouveaux libellés (nom mois déjà localisés, flèches aria-labels, légende).
- **Réutiliser le design system** : variables CSS existantes, pas de nouvelles polices.
- **Responsive** : le mois unique grand fonctionne mieux sur mobile que 3 mois. Sur petit écran, réduire la taille du titre et des chiffres, garder la lisibilité (touch targets ≥ 40px sur les flèches).
- **Accessibilité** : flèches = vrais `<button>` avec `aria-label`, `aria-live="polite"` sur le conteneur (déjà présent), navigation clavier.
- **API inchangée** : `availability.js` continue d'appeler `/availability` ; on change le rendu et la logique de navigation, pas le contrat réseau.

## Fichiers touchés

| Fichier | Changement |
|---------|-----------|
| `assets/js/availability.js` | Rendu mois unique + état navigation (mois courant) + flèches + rendu typographique des états |
| `assets/css/main.css` | Nouveau bloc `.cal-*` (grand mois, chiffres, point terracotta, flèches) ; refonte `.come-stay*` |
| `_includes/booking.html` / `booking-fr.html` | Nouvelle structure de la section homepage |
| `come-stay.html` / `fr/venir-dormir.html` | Repositionner le calendrier avant le CTA, resserrer le rythme |

## Hors scope

- Pas de changement au backend / API.
- Pas de sélection de dates ni de tunnel de réservation interactif (le calendrier reste **informationnel** : voir les dispos, puis écrire à Bolo).
- Pas de refonte du reste de la homepage (galerie, hero, etc.).
