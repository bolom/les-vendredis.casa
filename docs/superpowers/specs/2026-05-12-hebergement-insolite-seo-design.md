# Hebergement insolite Martinique - SEO design

**Date :** 2026-05-12
**Statut :** Approved
**Perimetre :** Page FR `/fr/hebergement-atypique-martinique/`, liens internes FR, schema FAQ

---

## Contexte

La requete cible est `hebergement insolite martinique`. Les resultats Google actuels mettent surtout en avant des pages francaises de Sainte-Luce et du sud Martinique autour des intentions `hebergement insolite`, `logement insolite`, `cabane`, `glamping`, `bulle`, `ecolodge`, souvent avec une promesse romantique ou nature.

Les Vendredis a deja la bonne page de destination, mais elle cible d'abord `hebergement atypique`. Google montre aussi la homepage anglaise pour une recherche francophone, ce qui indique que la page francaise doit porter plus clairement l'intention principale.

---

## Objectif

Faire de `/fr/hebergement-atypique-martinique/` la page de reference du site pour `hebergement insolite martinique`, sans changer son URL.

La page doit rester sincere : Les Vendredis n'est pas un lodge spa avec jacuzzi, piscine ou clim. Le positionnement doit transformer cette difference en signal clair : une cabane A-frame artisanale, un jardin tropical privatif, le calme des hauteurs de Sainte-Luce, les animaux acceptes, et un sejour nature sans equipements hoteliers.

---

## Approche retenue

### 1. Garder l'URL existante

L'URL `/fr/hebergement-atypique-martinique/` reste en place.

Raison : la page existe deja, elle est dans le sitemap FR, elle a un equivalent EN via `hreflang`, et changer l'URL maintenant risquerait de disperser l'autorite sur un petit site.

Une URL `/fr/hebergement-insolite-martinique/` pourra etre envisagee plus tard seulement si les donnees Search Console montrent que l'URL actuelle freine le taux de clic ou l'indexation.

### 2. Retargeting editorial

Le mot cle principal devient `hebergement insolite en Martinique`.

`Hebergement atypique` reste present comme synonyme naturel, pas comme cible principale.

Elements a retoucher :

- `seo_title`
- `description`
- `title`
- eyebrow
- H1
- lead
- premieres sections de contenu
- texte de lien depuis la homepage FR

### 3. Section de reponse a l'intention de recherche

Ajouter une section courte et explicite :

> Pourquoi choisir cet hebergement insolite en Martinique ?

La section doit couvrir :

- cabane A-frame construite a la main
- Sainte-Luce, sud Martinique
- jardin tropical privatif de 600 m2
- douche exterieure, cuisine equipee, eau chaude
- animaux acceptes
- proximite plages et Roches Gravees de Montravail
- absence assumee de piscine, jacuzzi, clim, television, wifi

### 4. FAQ et donnees structurees

Mettre a jour la FAQ visible et le `FAQPage` JSON-LD pour inclure les formulations que les visiteurs cherchent :

- Est-ce un hebergement insolite en Martinique ?
- Ou se trouve la cabane ?
- Y a-t-il piscine, jacuzzi, clim ou wifi ?
- Les animaux sont-ils acceptes ?
- Pour combien de personnes ?
- Comment reserver ?

Le schema `LodgingBusiness` reste en place, mais sa description doit reprendre l'intention principale.

### 5. Maillage interne FR

Renforcer le lien depuis la homepage FR vers la page cible avec une ancre plus directe :

> hebergement insolite en Martinique

Le footer garde son lien `La cabane`, mais la FAQ homepage doit envoyer un signal semantique plus fort.

---

## Ce qui ne change pas

- Pas de nouvelle page SEO concurrente
- Pas de changement d'URL
- Pas de redesign
- Pas de promesse de piscine, jacuzzi, clim, wifi ou service hotelier
- Pas de bourrage de mots-cles
- Pas de modification de la version anglaise sauf si necessaire pour le `hreflang`

---

## Fichiers a modifier

- `fr/hebergement-atypique-martinique.html`
- `_includes/faq-fr.html`
- `_includes/schema-faq-landing.html`

`_includes/schema-lodging.html` ne doit pas etre modifie pour ce chantier : il reprend deja `page.description`, donc le changement de frontmatter suffit pour enrichir le `LodgingBusiness`.

---

## Criteres de succes

- Le title, le H1 et le premier ecran ciblent clairement `hebergement insolite en Martinique`
- La page reste naturelle, specifique, et fidele au lieu
- `hebergement atypique` reste present comme variante secondaire
- Les absences importantes sont dites franchement pour eviter des clics de mauvaise qualite
- La homepage FR lie vers cette page avec une ancre pertinente
- Le site build sans erreur avec Jekyll
