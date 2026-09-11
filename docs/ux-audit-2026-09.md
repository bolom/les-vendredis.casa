# Audit UX/UI — Lesvendredis.casa · 2026-09

**Issue #80** · Audit complet + proposition de redesign V1.1
**Auteur :** Vendredi (agent du projet) · Relecture : Bolo

---

## 0. Synthèse exécutive

Le produit est fonctionnellement complet et le site public a une vraie identité (crème/encre/or/terracotta, Cormorant + Inter Tight, éditorial, mobile-first). Le problème n'est pas le style : c'est la **déperdition de l'identité sur les bords du parcours**.

- Le formulaire de réservation — l'écran le plus important du produit — est **pourvu de styles par défaut du navigateur**. C'est là que l'on perd les clients.
- Les emails transactionnels sont **en texte brut non signé** ; le site signe avec un footer soigné, les emails ne signent avec rien. Longtemps acceptable ; plus pour un produit qui a une confirmation WYSIWYG polie (PR #86).
- La connexion admin est la maquette Rails par défaut (anglais, flash rouge/vert en `style=""`). Simple à régler, fort effet.
- Le back-office a déjà son propre système de design (admin.css) et est plutôt bon ; sa dette est **structurelle** (navigation plate, messages d'état), pas stylistique.
- Le site reste beau, mais **2700 lignes de CSS en un seul fichier** rendent ses choix invisibles à quiconque intervient après.

**Ce que V1.1 signifie ici :** ne pas re-styler le site public — serrer les points de contact les moins soignés (formulaire, emails, login admin) et cacher derrière un design system documenté ce qui marche déjà.

---

## 1. Problèmes identifiés (priorisés)

### P1 — Formulaire de réservation sans style
Fichier : `app/views/booking_inquiries/new.html.erb`

Le plus gros écart de tout le produit. Les champs natifs du navigateur, pas de mise en page en deux colonnes, pas de groupes sur les nombres de voyageurs, pas de labels d'aide (dates, heure d'arrivée), l'erreur est un simple bloc `<div role="alert">`, le CTA est un bouton système. **C'est l'écran du moment de conversion** — tout ce qui précède construit la confiance, un formulaire brut la détruit au moment précis de la demande.

### P2 — Emails transactionnels en texte brut, sans marque
Fichiers : `app/views/booking_inquiry_mailer/*.text.erb`, `layouts/mailer.html.erb`

Contenu très bien écrit (ton humain, structure claire, les deux langues), mais zéro design : pas d'en-tête, pas de logo, pas de mise en valeur du prix ou de la référence, pas de signature visuelle. Un email qui dit « votre séjour est confirmé » mérite d'être un objet que l'on garde.

### P3 — Connexion admin = squelette Rails par défaut
Fichier : `app/views/sessions/new.html.erb`

Flash rouge/vert par styles en ligne, placeholders en anglais sur un site 100 % français, pas de contexte englobant (pas de logo, pas de rappel produit), pas de CTA stylisé. Utilisateurs : Bolo, Anaïs, les agents. Premier écran vu chaque jour dans le back-office.

### P4 — Back-office : navigation et architecture des états
Fichiers : `app/views/layouts/admin.html.erb`, `admin.css`

Visuellement propre (tokens chaleureux, mobile-first, accessibles), mais :
1. Navigation sur deux rangées plates avec **13 liens** et labels inhomogènes (« Journal », « Calendriers », « Réglages des séjours »), zone technique entassée derrière un bouton.
2. Emprunts décroissants entre pages : les tableaux et cartes ont des conversions approximatives.
3. Les états des demandes sont portés par le texte plutôt que par l'interface (applications en attente vs confirmées vs annulées).

### P5 — Design system : existant mais invisible
Fichier : `app/assets/stylesheets/application.css` (2 711 lignes)

Le site public a des conventions très cohérentes (variables, `.wrap`, échelle typographique, boutons/survol dichotomie primary/secondary), mais tout est dans un monolithe : on ne sait pas ce qui est réutilisable, les conventions ne sont pas écrites, il n'y a pas de page de référence. L'admin a un deuxième jeu de tokens parallèle (ports de ports non partagés). Journal + contenu = index/typographie aux classes proches mais découpées.

---

## 2. Recommandations priorisées

| # | Reco | Effort | Impact | Fait quand ? |
|---|------|--------|--------|------|
| **R1** | **Styler le formulaire de réservation** (Voir maquette M1) | S | Fort — conversion | V1.1 immédiat |
| **R2** | **Gagner des emails HTML signés** (Voir maquette M2) — un layout `mailer.html.erb` avec en-tête/footer/pied de page, et des emails clés uniquement (ack, acceptance) passent en HTML ; les autres restent texte | M | Fort — confiance post-résa | V1.1 |
| **R3** | **Reprendre la page de connexion admin** (Voir maquette M3) | S | Moyen (orgueil/finition) | V1.1 |
| **R4** | **Réorganiser la navigation admin** : une ligne Maison (5 liens max, grouper), techniques derrière le même bouton ; renommer « Calendriers » → « Sources iCal », « Réglages des séjours » → « Règles » | S | Moyen — usage quotidien | V1.1 |
| **R5** | **Extraire un début de design system** : page `/design` (dev only) montrant les composants existants + regrouper les tokens dans `ds.css` | M | Moyen — maintenabilité | V1.1→V1.2 |
| **R6** | Index journal en cartes (image + titre résumé, plutôt qu'une liste de texte pur) | M | Moyen | V1.2 |
| **R7** | Passe cohérence admin : formes, états, tableaux — réutiliser les classes admin.css existantes partout | M | Faible/Moyen | V1.2 |

**Reco n°1 (prioritaire) : R1 — styler le formulaire de réservation.** Plus petit changement, plus grand impact : c'est le dernier « température chute » entre un site au vrai caractère et un formulaire brut.

---

## 3. Direction visuelle — proposition V1.1

**Préservation :** le site public ne bouge pas. La proposition est d'**étendre l'identité existante** aux bords du produit, pas la réinventer.

### Palette (celle déjà en place, documentée)

| Nom | Hex | Rôle |
|-----|-----|------|
| Crème | `#F8F1E4` | Fond primaire |
| Crème doux | `#F2EAD9` | Fond secondaire, admin |
| Encre | `#1F1611` | Texte primaire |
| Encre doux | `#4A3A2D` | Texte secondaire |
| Doux | `#8C7B66` | Métadonnées, labels |
| Règle | `rgba(31,22,17,.14)` | Frontières, grilles |
| Or | `#B08A4D` | Ornement, filets |
| Terracotta | `#B85F38` | Accent, CTA, sélection |
| Admin états | `#35521f` / `#8c2a12` / `#6b4c10` | Ok / Problème / En attente (existants `admin.css`) |

### Typographie

- **Serif éditorial** : Cormorant Garamond (italique pour la marque, titres longs)
- **Sans** : Inter Tight, graisse 300-400, majuscules, lettres-espacées 0,2-0,3em pour les métadonnées/labels
- Échelle définie en `application.css` — la codifier ici

### Principes régissant le redesign

1. **Le ton est éditorial.** Une cabane écrite à la main, pas un SaaS. Éviter les gradients, les cartes à ombre volumineuses, les callouts à bord coloré — jusqu'au back-office.
2. **L'air parle.** Beaucoup d'espace blanc, des filets fins or/encre, pas de bordures dures.
3. **Une brique chauffée à la fois.** Le terracotta n'apparaît que là où l'on doit agir (CTA, accent actif). L'admin suit les mêmes règles — on remplace la redondance de ses tokens.
4. **Écrire en deux langues, picker en deux langues.** Chaque vue double FR/EN ; le design system doit le faciliter, pas s'en moquer.

### Rôle des écrans

| Surface | Personnalité |
|---|---|
| Site public | Éditorial, chaleureux, aéré — *telle quelle, à conserver* |
| Formulaire résa | Même éditoriale, plus « acté » : étapes claires, labels humains |
| Emails | Héritage de la même carte : crème, encre, sa signature or/terracotta |
| Admin maison | Calme, chaud, utilitaire (le fond d'admin.css est le bon) |

---

## 4. Écrans prioritaires — maquettes HTML simples

Ouvrir directement les fichiers dans le navigateur (pas de build). Ils reproduisent la palette/typographie inline.

- **M1 — Formulaire de réservation repensé** : maquette séparée, voyageurs en deux colonnes, dates en deux colonnes, texte d'aide léger
- **M2 — Email HTML « séjour confirmé »** : en-tête de marque, bloc de réservation mis en valeur, détails lisible, CTA au lien de confirmation, signature
- **M3 — Écran de connexion admin** : carte centrée sur fond crème, logo, champs, bouton terracotta

Fichiers :
- `docs/ux-mockups/mockup-booking-form.html`
- `docs/ux-mockups/mockup-email-confirmation.html`
- `docs/ux-mockups/mockup-admin-login.html`

---

## 5. Roadmap de redesign

### V1.1 — Serrer les points de contact (cible : ~1 semaine)
1. **M1 → code :** formulaire de réservation (CSS + structure HTML) — *R1*
2. **M2 → code :** layout email HTML + 2 emails clés en HTML, les autres restent texte — *R2*
3. **M3 → code :** écran de connexion admin — *R3*
4. **Renommer les entrées de menu admin** + fusionner les groupes — *R4*
5. Chaque lot : une branche/PR, screenshots avant/après dans la description.

### V1.2 — Cohérence & DS (cible : ~2 semaines)
6. Extraire `ds.css` (tokens partagés, boutons, formulaire, cartes, états) + page de référence `/design` — *R5*
7. Passe cohérence admin (tableaux, formulaires, états) en re-utilisant admin.css — *R7*
8. Index journal en cartes — *R6*

### V1.3 — Au-delà
- Composant calendrier de disponibilité rendu modulaire/documentation
- Thème sombre admin (optionnel)
- Animation transversale d'entrée (optionnel)

### Non-objectifs (V1.x)
- Aucun framework CSS (Tailwind etc.) — l'application est déjà cohérente, un framework déplacerait le problème
- Pas de refonte visuelle du site public
- Pas d'ajout de pages / de fonctions nouvelles dans le périmètre UI

---

## Annexe — critères de réussite issue #80

- [x] Direction visuelle claire définie (§3) — *proposer un renforcement de l'existante plutôt qu'une nouvelle direction*
- [x] Interfaces publiques et admin cohérentes → plan R1-R4 pour ce qui diverge
- [x] Priorités identifiées (P1-P5, R1-R7)
- [x] Travail permet d'organiser les prochaines évolutions → roadmap V1.1/V1.2/V1.3
